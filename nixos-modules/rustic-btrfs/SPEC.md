# rustic-btrfs Specification

## Overview

**rustic-btrfs** is a command-line tool that safely backs up Btrfs subvolumes using the rustic backup system. It creates read-only snapshots, backs them up via rustic, and cleans up afterward.

**Version**: 1.0.0
**Language**: Rust (edition 2024)
**Target Platform**: Linux (x86_64, aarch64)

## Purpose

Enable safe, consistent backups of Btrfs subvolumes by:

1. Creating a read-only Btrfs snapshot
2. Backing up the snapshot using rustic_core
3. Deleting the snapshot after backup completes

## Architecture

### Core Components

```
rustic-btrfs (CLI binary)
├── traits module (testability interfaces)
│   ├── BtrfsOps trait
│   └── BackupOps trait
├── btrfs module (libbtrfsutil bindings)
│   ├── LibBtrfs (impl BtrfsOps)
│   ├── get_subvolume_uuid()
│   ├── create_snapshot()
│   └── delete_subvolume()
├── backup module (rustic_core integration)
│   ├── RusticBackup (impl BackupOps)
│   ├── configure_repository()
│   └── run_backup()
├── lock module (fs4-based locking)
│   └── acquire_lock()
├── mocks module (test doubles, #[cfg(test)] only)
│   ├── MockBtrfs (impl BtrfsOps)
│   └── MockBackup (impl BackupOps)
└── cli module (clap-based CLI)
    ├── parse_arguments()
    └── generate_completions()
```

### Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| CLI framework | `clap` | Argument parsing |
| Shell completion | `clap_complete` | Runtime completion generation |
| Manpage generation | `clap_mangen` | Generate man pages |
| Logging | `env_logger` | Structured logging with syslog support |
| Progress display | `indicatif` | Progress bars (TTY only) |
| File locking | `fs4` | Exclusive file locks |
| Btrfs integration | `libbtrfsutil` (via `bindgen`) | Subvolume operations, UUID retrieval |
| Backup engine | `rustic_core` | Backup operations |
| JSON generation | `serde_json` | Metadata serialization (partial backup descriptions) |

### Dependencies

#### Build-time

- `bindgen = "0.70"` - Generate libbtrfsutil FFI bindings
- `pkg-config` - Locate system libraries
- `clang` - Required by bindgen

#### Runtime (Rust crates)

- `fs4 = "0.9"` - File locking
- `clap` (with `derive`, `env` features) - CLI
- `clap_complete` - Shell completions
- `clap_mangen` - Manpage generation
- `env_logger` - Logging
- `indicatif` - Progress bars
- `rustic_core` - Backup functionality
- `serde` (with `derive` feature) - Serialization framework
- `serde_json` - JSON generation for metadata

**Note**: `rustic_core` likely already depends on `serde`, so minimal additional overhead.

#### System libraries

- `libbtrfsutil` (from btrfs-progs) - Btrfs operations

#### Runtime binaries (PATH)

- `rclone` - Required for rustic_core remote backends

## Functional Specification

### 1. Snapshot Management

#### 1.1 Snapshot Location

Snapshots are created at: `<subvolume>/.snapshot`

**Properties**:

- Read-only Btrfs subvolume
- Created using `libbtrfsutil`'s `btrfs_util_create_snapshot()` with read-only flag
- Deleted after backup (successful or failed) using `btrfs_util_delete_subvolume()`

#### 1.2 Snapshot Conflict Resolution

When `.snapshot` already exists:

| Condition | Action |
|-----------|--------|
| Is Btrfs subvolume | Log WARNING, delete it, create new snapshot |
| Is regular directory/file | Log ERROR, exit with error code |
| Does not exist | Create snapshot normally |

**Rationale**: Btrfs subvolume indicates stale snapshot from previous failed run (safe to delete). Regular directory indicates user data (unsafe to delete).

#### 1.3 Snapshot Timestamp

Capture timestamp **immediately after snapshot creation** using:

- Format: ISO 8601 UTC (e.g., `2025-01-15T14:30:00Z`)
- Source: `std::time::SystemTime::now()`
- Usage: Passed to rustic_core as backup time via `--time`

### 2. Locking Mechanism

#### 2.1 Lock File Location

```
/run/lock/rustic-btrfs/<subvolume-uuid>.lock
```

**UUID Acquisition**:

- Use `libbtrfsutil`'s `btrfs_util_subvolume_info()` via FFI
- Extract UUID from `btrfs_util_subvolume_info.uuid` field
- Format as RFC 4122: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

**Directory Setup**:

- Lock directory `/run/lock/rustic-btrfs/` created via systemd tmpfiles.d
- Owner: `restic:restic`
- Permissions: `0755`
- Configured in NixOS module using `systemd.tmpfiles.rules`

#### 2.2 Lock Behavior

```rust
use fs4::FileExt;

let lock_file = File::create(lock_path)?;
match lock_file.try_lock_exclusive() {
    Ok(_) => {
        // Proceed with backup
        // Lock automatically released when file/process exits
    }
    Err(_) => {
        // Another process is backing up this subvolume
        log::error!("Another backup is already running for this subvolume");
        std::process::exit(1);
    }
}
```

**Characteristics**:

- Non-blocking exclusive lock (fail-fast if locked)
- Automatic cleanup on process exit (even on crash)
- Prevents concurrent backups of same subvolume
- Allows multiple configs for same subvolume (sequential execution)

### 3. Rustic Integration

#### 3.1 Using rustic_core

**Not using**: Spawning `rustic` binary as subprocess
**Using**: `rustic_core` crate as library

**Benefits**:

- Type-safe API (no JSON parsing)
- Direct error handling (Rust `Result` types)
- Progress callbacks (native Rust)
- No external binary dependency

#### 3.2 Repository Configuration

**Required Configuration**:

- Repository location (required)
- Password/authentication method (required)

**Configuration Sources** (priority order):

1. CLI options (e.g., `--repository`, `--password-file`)
2. Environment variables (e.g., `RUSTIC_REPOSITORY`, `RUSTIC_PASSWORD_FILE`)

**Implementation**:

- rustic-btrfs reads CLI options and environment variables directly
- Configuration is then passed to rustic_core via its API
- rustic-btrfs handles validation before invoking rustic_core

**Supported Environment Variables**:

- `RUSTIC_REPOSITORY` - Repository location
- `RUSTIC_PASSWORD_FILE` - Path to password file
- `RUSTIC_PASSWORD_COMMAND` - Command to retrieve password
- `RUSTIC_PASSWORD` - Password (less secure, not recommended)

**Validation**:

- Exit with error if repository not configured
- Exit with error if no password method configured

#### 3.3 Backup Parameters

**Fixed Parameters** (always passed to rustic_core):

- `--no-scan` - Don't scan repository
- `--one-file-system` - Don't cross filesystem boundaries
- `--ignore-devid` - Ignore device ID changes
- `--time <timestamp>` - Use snapshot creation timestamp

**Conditional Parameters**:

- **Full backup** (no `--paths` specified):
    - Backup source: `<subvolume>/.snapshot`
    - `--as-path <original-path>` - Store with original subvolume path (not `.snapshot`)

- **Partial backup** (`--paths` specified):
    - Backup source: `<subvolume>/.snapshot`
    - `--glob '<subvolume>/.snapshot/<path>/**'` - Full-path glob for each path in `--paths`
    - `--as-path <original-path>` - Store with original subvolume path (not `.snapshot`)
    - Multiple `--glob` patterns if multiple paths specified

**Example Command Translation**:

```bash
# User command:
rustic-btrfs --paths user/Documents,user/Photos /home

# Translates to rustic_core:
rustic backup /home/.snapshot \
  --glob '/home/.snapshot/user/Documents/**' \
  --glob '/home/.snapshot/user/Photos/**' \
  --as-path /home
```

**Default Parameters**:

- `--group-by host,paths` - Group by host and paths for parent detection

#### 3.4 User-Configurable Parameters

##### Parent Processing Options

```
--group-by <CRITERION>     Group snapshots (default: host,paths)
--parent <SNAPSHOT>        Specific parent snapshot
--skip-if-unchanged        Skip if unchanged vs parent
--force                    No parent, read all files
--ignore-ctime             Ignore ctime changes
--ignore-inode             Ignore inode changes
```

##### Exclude Options

```
--glob <GLOB>              Glob pattern to exclude/include
--iglob <GLOB>             Case-insensitive glob
--glob-file <FILE>         Read patterns from file
--iglob-file <FILE>        Case-insensitive glob file
--git-ignore               Use .gitignore rules
--no-require-git           Don't require git repo for git-ignore
--custom-ignorefile <FILE> Treat file as .gitignore
--exclude-if-present <FILE> Exclude dirs containing this file
--exclude-larger-than <SIZE> Exclude files larger than size
```

##### Snapshot Metadata Options

```
--label <LABEL>            Label for snapshot
--tag <TAG[,TAG,..]>       Tags (can be specified multiple times)
--description <DESC>       Snapshot description (overrides auto-generated)
--description-from <FILE>  Read description from file
--time <TIME>              Override backup time (ISO 8601)
--delete-never             Mark as uneraseable
--delete-after <DURATION>  Auto-delete after duration
--host <NAME>              Override hostname
```

**Auto-generated Description**:

When `--paths` is specified but `--description` is not:

- Automatically generate JSON description with included paths
- Format: `{"included_paths": ["path1", "path2", ...]}`
- Example: `--paths user/Documents,user/Photos` → `{"included_paths": ["user/Documents", "user/Photos"]}`
- User can override with explicit `--description`

**Priority**:

1. `--description` (user-specified) - highest priority
2. `--description-from` (from file)
3. Auto-generated JSON (if `--paths` specified)
4. None (full backup)

**Rationale**: JSON format enables programmatic parsing and future extensibility.

**Implementation**:

```rust
use serde_json::json;

fn generate_partial_backup_description(paths: &[String]) -> String {
    json!({
        "included_paths": paths
    }).to_string()
}
```

This ensures:

- Proper JSON escaping (handles special characters in paths)
- Valid JSON structure
- Safe handling of quotes, backslashes, and unicode

##### Partial Backup (v1 Feature)

```
--paths <PATH[,PATH,..]>   Backup only specific paths within subvolume
```

**Behavior**:

- User specifies relative paths (relative to subvolume root): `Wallpapers,Documents`
- Snapshot created for entire subvolume: `/foo` → `/foo/.snapshot`
- rustic_core invoked with:
    - Backup source: `/foo/.snapshot`
    - Glob patterns: `--glob '/foo/.snapshot/Wallpapers/**'` `--glob '/foo/.snapshot/Documents/**'`
    - As-path: `--as-path /foo`
- Paths stored in repository: `/foo/Wallpapers/...`, `/foo/Documents/...` (no `.snapshot`)

**Examples**:

```bash
# Backup only user/Documents and user/Photos from /home subvolume
rustic-btrfs --paths user/Documents,user/Photos /home
# Translates to:
# rustic backup /home/.snapshot \
#   --glob '/home/.snapshot/user/Documents/**' \
#   --glob '/home/.snapshot/user/Photos/**' \
#   --as-path /home

# Backup single directory
rustic-btrfs --paths etc/nginx /
# Translates to:
# rustic backup /.snapshot --glob '/.snapshot/etc/nginx/**' --as-path /

# Backup Wallpapers directory
rustic-btrfs --paths Wallpapers /foo
# Translates to:
# rustic backup /foo/.snapshot --glob '/foo/.snapshot/Wallpapers/**' --as-path /foo
```

**Path Validation**:

- Paths must be relative (no leading `/`)
- Paths must not contain `..` (parent directory references)
- Invalid paths result in error before snapshot creation

**Metadata**:

- If `--description` not specified, auto-generate JSON: `{"included_paths": ["path1", "path2", ...]}`
- This helps identify partial backups in the repository programmatically
- Example: `{"included_paths": ["user/Documents", "user/Photos"]}`
- JSON format allows easy parsing with `rustic snapshots --json | jq`

**Querying Partial Backups**:

```bash
# List all partial backups
rustic snapshots --json | jq '.[] | select(.description | contains("included_paths"))'

# Find backups containing specific path
rustic snapshots --json | jq '.[] | select(.description | fromjson | .included_paths | contains(["user/Documents"]))'

# Extract included paths from a snapshot
rustic snapshots --json | jq '.[0].description | fromjson | .included_paths'
```

**Restore Considerations**:

Partial backups are stored with original paths (no `.snapshot`), making restore straightforward:

```bash
# Partial backup of /home with --paths user/Documents
# Repository contains: /home/user/Documents/...

# Restore to original location
rustic restore <snapshot-id> --target /

# Files restored to: /home/user/Documents/... ✓

# Or restore to different location
rustic restore <snapshot-id> --target /mnt/restore
# Files restored to: /mnt/restore/home/user/Documents/...
```

**Note**: Thanks to `--as-path`, partial backups restore to the same paths as full backups.

#### 3.5 Progress Reporting

**TTY Detection**:

```rust
use std::io::IsTerminal;

if std::io::stdout().is_terminal() {
    // Show progress bar using indicatif
} else {
    // Log to env_logger only (for systemd journal)
}
```

**Progress Bar** (TTY mode):

- Use `indicatif::ProgressBar`
- Integrate with rustic_core's progress reporting mechanism
- Display backup progress with file counts and data transferred
- Implementation details determined by rustic_core's actual API

**Logging** (non-TTY mode):

- Log major milestones at INFO level:
    - `INFO: Starting backup of subvolume /home`
    - `INFO: Created snapshot at /home/.snapshot`
    - `INFO: Backup completed: 1.8GB in 45s`

**Note**: Specific progress callback implementation will be determined during development based on rustic_core's API.

#### 3.6 Error Handling

**rustic_core errors**:

- Return as-is (Rust `Result::Err`)
- Log error details at ERROR level
- Exit with rustic_core's error code (or map to appropriate exit code)

### 4. Error Handling Strategy

#### 4.1 Error Scenarios

| Scenario | Action | Exit Code | Cleanup |
|----------|--------|-----------|---------|
| Lock acquisition fails | Log ERROR, exit immediately | 1 | None |
| `.snapshot` is not a subvolume | Log ERROR, exit immediately | 1 | None |
| Snapshot creation fails | Log ERROR, exit immediately | 1 | None |
| Backup fails | Log ERROR, **delete snapshot**, exit | rustic_core error code | Delete snapshot |
| Snapshot deletion fails (after success) | Log WARNING, exit success | 0 | Best-effort cleanup attempted |
| Snapshot deletion fails (after backup error) | Log WARNING, exit with backup error | rustic_core error code | Best-effort cleanup attempted |

#### 4.2 Cleanup Guarantee

**Always attempt snapshot cleanup**, even on backup failure:

```rust
let snapshot_path = create_snapshot(subvolume)?;
let backup_result = run_backup(&snapshot_path);

// Always try to delete snapshot
if let Err(e) = delete_snapshot(&snapshot_path) {
    log::warn!("Failed to delete snapshot: {}", e);
    // Continue - don't override backup_result
}

// Return backup result (success or error)
backup_result?;
```

### 5. Logging

#### 5.1 Log Format

**Systemd Detection**:

- Detects systemd journal via `JOURNAL_STREAM` environment variable
- When running under systemd, uses syslog priority format
- Timestamp is omitted (systemd adds it automatically)

**Systemd Format** (JOURNAL_STREAM present):

```
<6>INFO: Created snapshot at /home/.snapshot
<4>WARN: Snapshot deletion failed, manual cleanup required
<3>ERROR: Backup failed: repository not found
<7>DEBUG: Lock acquired successfully
```

Format: `<priority>SEVERITY: message`

**Syslog Priority Mapping**:

| Log Level | Syslog Priority | Description |
|-----------|-----------------|-------------|
| ERROR     | 3               | Error conditions |
| WARN      | 4               | Warning conditions |
| INFO      | 6               | Informational messages |
| DEBUG     | 7               | Debug-level messages |
| TRACE     | 7               | Debug-level messages |

**Terminal Format** (JOURNAL_STREAM not present):

```
2026-01-01T17:21:56+09:00: INFO: Created snapshot at /home/.snapshot
2026-01-01T17:22:10+09:00: WARN: Snapshot deletion failed
2026-01-01T17:22:10+09:00: ERROR: Backup failed: repository not found
2026-01-01T17:22:10+09:00: DEBUG: Lock acquired successfully
```

Format: `YYYY-MM-DDTHH:MM:SS±TZ: SEVERITY: message` (localtime with timezone)

#### 5.2 Log Levels

**Default**: `INFO`

**With `--debug` flag**: `DEBUG`

**Control via `RUST_LOG`**: Also supported (e.g., `RUST_LOG=rustic_btrfs=trace`)

#### 5.3 Key Log Messages

**INFO level**:

- Starting backup of subvolume
- Snapshot created
- Backup progress milestones (if not TTY)
- Backup completed with stats
- Snapshot deleted

**WARNING level**:

- Existing `.snapshot` found and deleted (stale)
- Snapshot deletion failed (after successful backup)

**ERROR level**:

- Lock acquisition failed (another backup running)
- `.snapshot` exists as regular directory
- Snapshot creation failed
- Backup failed
- Required configuration missing

**DEBUG level**:

- Detailed rustic_core operations
- Lock file operations
- UUID resolution
- Parameter passing details
- Auto-generated description (for partial backups)

### 6. Command-Line Interface

#### 6.1 Basic Usage

```bash
rustic-btrfs [OPTIONS] <SUBVOLUME>
rustic-btrfs [OPTIONS] -- <SUBVOLUME>
```

**Positional Arguments**:

- `<SUBVOLUME>` - Path to Btrfs subvolume to backup

**Option Parsing**:

- `--` - Stops option parsing, treats remainder as positional arguments
- Useful when subvolume path starts with `-` or for clarity
- Automatically supported by `clap` (no special configuration needed)

**Examples**:

```bash
# Basic backup
rustic-btrfs /home

# Backup with tags
rustic-btrfs --tag daily --label "home-backup" /home

# Partial backup (paths relative to subvolume)
# Auto-generates JSON description: {"included_paths": ["user/Documents", "user/Photos"]}
rustic-btrfs --paths user/Documents,user/Photos /home

# Partial backup with custom description (overrides auto-generated JSON)
rustic-btrfs --paths user/Documents --description "Monthly documents backup" /home

# Using -- for clarity (explicit option/argument separation)
rustic-btrfs --paths user/Documents,user/Photos -- /home

# Subvolume path starts with - (requires --)
rustic-btrfs -- /-special-mount

# Dry run
rustic-btrfs --dry-run /home

# Debug logging
rustic-btrfs --debug /home
```

#### 6.2 Global Options

```
--debug                    Enable debug logging
--dry-run                  Pass --dry-run to rustic (no actual backup)
--repository <REPO>        Override RUSTIC_REPOSITORY
--password-file <FILE>     Override RUSTIC_PASSWORD_FILE
```

#### 6.3 Rustic Options

All rustic options from section 3.4 are supported.

#### 6.4 Special Options

```
--generate-completion <SHELL>    Generate shell completion
                                 Shells: bash, fish, zsh, elvish, powershell

--generate-manpage              Generate man page to stdout
```

**Usage**:

```bash
# Install bash completion
rustic-btrfs --generate-completion bash > /etc/bash_completion.d/rustic-btrfs

# View man page
rustic-btrfs --generate-manpage | man -l -
```

#### 6.5 Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error (lock, config, snapshot, etc.) |
| Other | rustic_core error code (passed through) |

### 7. FFI Bindings (libbtrfsutil)

#### 7.1 Build Process

**build.rs**:

```rust
use bindgen;

fn main() {
    println!("cargo:rustc-link-lib=btrfsutil");

    bindgen::Builder::default()
        .header_contents("wrapper.h", "#include <btrfsutil.h>")
        .allowlist_function("btrfs_util_.*")  // All btrfs_util functions
        .allowlist_type("btrfs_util_.*")      // All btrfs_util types
        .allowlist_var("BTRFS_UTIL_.*")       // All btrfs_util constants
        .rustified_enum("btrfs_util_error")
        .layout_tests(false)
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file(concat!(env!("OUT_DIR"), "/btrfs_bindings.rs"))
        .expect("Couldn't write bindings");
}
```

**Rationale**: Binding all `btrfs_util_*` functions provides flexibility for future enhancements (e.g., `btrfs_util_is_subvolume` for conflict detection) without requiring build script modifications.

#### 7.2 Wrapper Module

**src/btrfs.rs**:

```rust
include!(concat!(env!("OUT_DIR"), "/btrfs_bindings.rs"));

pub fn get_subvolume_uuid(path: &Path) -> Result<String, Error>;
pub fn create_snapshot(source: &Path, dest: &Path, readonly: bool) -> Result<(), Error>;
pub fn delete_snapshot(path: &Path) -> Result<(), Error>;
```

#### 7.3 UUID Formatting

**Format**: RFC 4122 (lowercase, hyphenated)

```
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

**Example**: `5ea01852-b4f9-4e4a-9c9d-f9c8b7a6e5d4`

## NixOS Integration

### 1. Package Definition

#### 1.1 flake-module.nix

```nix
{
  packages.rustic-btrfs = craneLib.buildPackage {
    src = ./.;

    nativeBuildInputs = with pkgs; [
      pkg-config
      clang  # For bindgen
    ];

    buildInputs = with pkgs; [
      btrfs-progs  # Provides libbtrfsutil
    ];

    # Bindgen requires libclang
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

    # Post-install: wrap binary, install completions/manpage
    postInstall = ''
      # Wrap with rclone in PATH
      wrapProgram "$out/bin/rustic-btrfs" \
        --prefix PATH : "${lib.makeBinPath [ pkgs.rclone ]}"

      # Generate and install shell completions
      for shell in bash fish zsh elvish powershell; do
        $out/bin/rustic-btrfs --generate-completion "$shell" > "rustic-btrfs.$shell"
      done

      # Install completions (NixOS 25.05: elvish, powershell not supported)
      installShellCompletion rustic-btrfs.{bash,fish,zsh}

      # Generate and install manpage
      mkdir -p $out/share/man/man1
      $out/bin/rustic-btrfs --generate-manpage > $out/share/man/man1/rustic-btrfs.1
    '';
  };
}
```

### 2. NixOS Module

#### 2.1 Module Structure

**File**: `nixos-module.nix`

**Option path**: `my.services.rustic-btrfs.backups.<name>`

#### 2.2 Configuration Schema

```nix
my.services.rustic-btrfs.backups = {
  # Each backup has a unique name
  home-to-s3 = {
    # Required: subvolume path
    subvolume = "/home";

    # Required: environment variables file
    # Should contain RUSTIC_REPOSITORY, RUSTIC_PASSWORD_*, etc.
    environmentFile = "/run/secrets/rustic-home.env";

    # Optional: systemd timer configuration
    timerConfig = {
      OnCalendar = "daily";  # Default
      RandomizedDelaySec = "1h";
      Persistent = true;
    };

    # Optional: rustic backup options (relative paths)
    paths = [ "user/Documents" "user/Photos" ];  # Partial backup
    tags = [ "daily" "auto" ];
    label = "home-backup";
    description = "Daily home directory backup";  # Overrides auto-generated

    # Parent processing
    groupBy = "host,paths";  # Default
    skipIfUnchanged = true;

    # Exclude options
    globs = [ "*.tmp" "*.cache" ];
    gitIgnore = true;
    excludeIfPresent = [ ".nobackup" ];
  };

  home-to-local = {
    # Same subvolume, different destination
    subvolume = "/home";
    environmentFile = "/run/secrets/rustic-local.env";
    timerConfig.OnCalendar = "hourly";
    tags = [ "hourly" "local" ];
    # No description specified → full backup, no auto-generated description
  };

  docs-backup = {
    # Partial backup with auto-generated JSON description
    subvolume = "/home";
    environmentFile = "/run/secrets/rustic-docs.env";
    paths = [ "user/Documents" ];
    # description not specified → auto-generates: {"included_paths": ["user/Documents"]}
    tags = [ "docs" ];
  };
};
```

#### 2.3 Generated systemd Units

For each backup `<name>`, generate:

**Service**: `rustic-btrfs-<escaped-name>.service`

(Note: `<escaped-name>` is the backup name with systemd path escaping applied using `systemd.lib.escapeSystemdPath` if needed)

```ini
[Unit]
Description=Rustic Btrfs Backup: <name>
After=network-online.target

[Service]
Type=oneshot
User=restic
Group=restic

# Environment
EnvironmentFile=<environmentFile>

# Capabilities (run as non-root)
AmbientCapabilities=CAP_SYS_ADMIN CAP_DAC_READ_SEARCH

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/run/lock

# Network (required for remote repositories)
PrivateNetwork=false

# Execute backup
ExecStart=/run/current-system/sw/bin/rustic-btrfs \
  --tag <tags...> \
  --label <label> \
  <other-options> \
  <subvolume>
```

**Timer**: `rustic-btrfs-<escaped-name>.timer`

```ini
[Unit]
Description=Timer for Rustic Btrfs Backup: <name>

[Timer]
OnCalendar=<timerConfig.OnCalendar>
RandomizedDelaySec=<timerConfig.RandomizedDelaySec>
Persistent=<timerConfig.Persistent>

[Install]
WantedBy=timers.target
```

#### 2.4 User and Group

**System user**: `restic`

```nix
users.users.restic = {
  isSystemUser = true;
  group = "restic";
  description = "Rustic backup service user";
};

users.groups.restic = {};
```

#### 2.5 Lock Directory Setup

**tmpfiles.d Configuration**:

```nix
systemd.tmpfiles.rules = [
  "d /run/lock/rustic-btrfs 0755 restic restic - -"
];
```

This ensures the lock directory exists with proper permissions for the `restic` user to create lock files.

#### 2.6 Capability Requirements

**CAP_SYS_ADMIN**:

- Required for: `btrfs subvolume snapshot`, `btrfs subvolume delete`
- Allows: Btrfs-specific ioctl operations

**CAP_DAC_READ_SEARCH**:

- Required for: Reading files owned by other users (e.g., root:root)
- Allows: Bypass discretionary access control for read operations

**Security consideration**: These are powerful capabilities. Document that:

- `restic` user should be dedicated to backup operations only
- `environmentFile` should have restricted permissions (0600, root:root)
- Alternative: Run as `root` (less secure but simpler)

#### 2.7 Multiple Backups of Same Subvolume

**Supported**: Yes

**Behavior**:

- Each backup gets its own systemd service/timer
- Lock file uses subvolume UUID (shared across configs)
- Concurrent execution prevented by lock
- Sequential execution allowed (one after another)

**Example**:

```nix
backups.home-to-s3.subvolume = "/home";      # Timer: daily
backups.home-to-local.subvolume = "/home";   # Timer: hourly

# If both timers trigger simultaneously:
# - First one acquires lock, starts backup
# - Second one fails to acquire lock, exits with error
# - systemd will retry second one on next timer cycle
```

### 3. NixOS Module Testing

#### 3.1 Test Scope

**Basic test only** (nixosTest):

- Service can start without errors
- Service can stop cleanly
- Timer is enabled and configured correctly

**Test file**: `nixos-module-test.nix`

```nix
import <nixpkgs/nixos/tests/make-test-python.nix> {
  name = "rustic-btrfs-basic";

  nodes.machine = { config, pkgs, ... }: {
    imports = [ ./nixos-module.nix ];

    my.services.rustic-btrfs.backups.test = {
      subvolume = "/test-subvol";
      environmentFile = pkgs.writeText "rustic.env" ''
        RUSTIC_REPOSITORY=/tmp/test-repo
        RUSTIC_PASSWORD=test
      '';
      timerConfig.OnCalendar = "daily";
    };
  };

  testScript = ''
    machine.start()

    # Check service exists
    machine.succeed("systemctl list-unit-files | grep rustic-btrfs@test.service")

    # Check timer exists and is enabled
    machine.succeed("systemctl is-enabled rustic-btrfs@test.timer")

    # Note: Not testing actual backup (requires btrfs filesystem setup)
  '';
}
```

## Testing Strategy

### 1. Testability Architecture

To enable comprehensive testing while minimizing complexity, use minimal trait abstraction:

**Trait Definitions** (`src/traits.rs`):

```rust
pub trait BtrfsOps {
    fn get_subvolume_uuid(&self, path: &Path) -> Result<String, Error>;
    fn is_subvolume(&self, path: &Path) -> Result<bool, Error>;
    fn create_snapshot(&self, source: &Path, dest: &Path, readonly: bool) -> Result<(), Error>;
    fn delete_subvolume(&self, path: &Path) -> Result<(), Error>;
}

pub trait BackupOps {
    fn run_backup(&self, config: &BackupConfig) -> Result<BackupStats, Error>;
}
```

**Production Implementation** (`src/btrfs.rs`, `src/backup.rs`):

```rust
pub struct LibBtrfs;  // Uses actual libbtrfsutil
pub struct RusticBackup;  // Uses actual rustic_core

impl BtrfsOps for LibBtrfs { /* real implementation */ }
impl BackupOps for RusticBackup { /* real implementation */ }
```

**Test Implementation** (`src/mocks.rs` with `#[cfg(test)]`):

```rust
#[cfg(test)]
pub struct MockBtrfs {
    pub fail_snapshot: bool,
    pub snapshots_created: RefCell<Vec<PathBuf>>,
    // ...
}

#[cfg(test)]
impl BtrfsOps for MockBtrfs { /* mock implementation */ }
```

**Design Principle**: Traits exist solely for testability, not for polymorphism or abstraction.

### 2. Unit Tests

**Location**: `src/**/*.rs` (inline `#[cfg(test)]` modules)

**Coverage**:

- UUID parsing and formatting
- Path validation (for --paths option)
- CLI argument parsing
- Error handling paths
- Business logic with mocked dependencies

**Example**:

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use crate::mocks::MockBtrfs;

    #[test]
    fn test_snapshot_cleanup_on_backup_failure() {
        let btrfs = MockBtrfs::new();
        let backup = MockBackup { should_fail: true };

        let result = run_backup_workflow(&btrfs, &backup, "/home");

        assert!(result.is_err());
        assert!(btrfs.snapshots_created.borrow().is_empty());  // Cleaned up
    }
}
```

### 3. Integration Tests

**Location**: `tests/*.rs`

**Coverage**:

- End-to-end CLI execution with mocked backends
- Snapshot creation → backup → cleanup flow
- Error scenarios (lock conflicts, snapshot failures, backup failures)
- Concurrent backup prevention (using real file locks)

**Example**:

```rust
#[test]
fn test_concurrent_backup_prevented() {
    let lock_dir = TempDir::new().unwrap();

    // First backup acquires lock
    let _guard1 = acquire_lock(&lock_dir, "test-uuid").unwrap();

    // Second backup should fail
    let result = acquire_lock(&lock_dir, "test-uuid");
    assert!(result.is_err());
}
```

### 4. Real Btrfs Integration Tests

**Location**: `tests/btrfs_real_test.rs`

**Purpose**: Verify actual Btrfs operations using real kernel interfaces and FFI bindings.

**Environment Setup**:

The test environment is automatically created using a loop device:

- **Image file**: `/tmp/rustic-btrfs-test-{pid}.img` (100MB)
- **Loop device**: Automatically allocated (e.g., `/dev/loop0`)
- **Mount point**: `/tmp/rustic-btrfs-test-mount-{pid}`
- **Cleanup**: Guaranteed via shell trap (umount, detach loop device, remove files)

**Requirements**:

- Root privileges (required for loop device management and Btrfs operations)
- System commands: `losetup`, `mkfs.btrfs`, `mount`, `umount`
- Kernel with Btrfs support
- `btrfs-progs` package installed

**Coverage**:

- **Snapshot creation and deletion**: Verify actual Btrfs snapshot operations on real filesystem
- **UUID retrieval**: Test UUID extraction from real subvolumes
- **UUID format validation**: Verify RFC 4122 format (lowercase, hyphenated)
- **`is_subvolume()` verification**: Differentiate between real subvolumes and regular directories
- **Read-only snapshot enforcement**: Verify write operations fail on read-only snapshots
- **Actual error codes**: Validate error messages from libbtrfsutil FFI calls

**Running Tests**:

```bash
# Via justfile (recommended - handles loop device setup/cleanup)
sudo -E just test-btrfs-real

# Output example:
# Creating 100MB image at /tmp/rustic-btrfs-test-12345.img...
# Setting up loop device...
# Loop device: /dev/loop0
# Formatting as Btrfs...
# Mounting at /tmp/rustic-btrfs-test-mount-12345...
# Running real Btrfs integration tests...
# running 4 tests
# test test_real_is_subvolume ... ok
# test test_real_readonly_snapshot ... ok
# test test_real_snapshot_creation_and_deletion ... ok
# test test_real_uuid_retrieval_and_format ... ok
# test result: ok. 4 passed; 0 failed; 0 ignored; 0 measured
# Cleaning up...
# Tests completed successfully
```

**Automatic Skipping**:

Tests automatically skip if `BTRFS_TEST_PATH` environment variable is not set. This allows running the regular test suite without root privileges:

```bash
# These skip real Btrfs tests automatically
cargo test
just test
just test-integration
```

**CI/CD Considerations**:

- Typically skipped in CI unless running in privileged container
- Requires privileged mode in Docker: `docker run --privileged`
- GitHub Actions: Requires Linux runner with root access

**Why Real Tests Matter**:

Mock-based tests cannot catch:

- FFI binding signature mismatches
- Incorrect libbtrfsutil function calls
- Actual Btrfs kernel behavior differences
- Real permission and capability issues
- Actual error codes and messages from the kernel

### 5. Manual Testing

**Prerequisites**:

- Btrfs filesystem with test subvolume
- Configured rustic repository

**Test cases**:

1. Successful backup flow
2. Stale `.snapshot` cleanup
3. `.snapshot` as directory (error case)
4. Lock file prevents concurrent runs
5. Backup failure triggers snapshot cleanup
6. Progress bar displays in TTY
7. Systemd journal receives syslog-formatted logs

## Implementation Checklist

### Phase 1: Foundation

- [ ] Project setup with Cargo.toml, lints, rustfmt
- [ ] build.rs with bindgen for libbtrfsutil
- [ ] Trait definitions (BtrfsOps, BackupOps)
- [ ] Basic btrfs module (UUID retrieval, LibBtrfs struct)
- [ ] Lock module (fs4-based locking)
- [ ] Mock implementations (MockBtrfs, MockBackup)

### Phase 2: Core Functionality

- [ ] Snapshot creation and deletion (via BtrfsOps trait)
- [ ] Snapshot conflict detection/resolution (is_subvolume)
- [ ] Lock acquisition and release
- [ ] Basic rustic_core integration (via BackupOps trait)

### Phase 3: CLI

- [ ] Clap-based CLI definition
- [ ] All rustic option passthrough
- [ ] Shell completion generation
- [ ] Manpage generation

### Phase 4: Logging and Progress

- [ ] env_logger integration with systemd detection
- [ ] indicatif progress bars (TTY detection)
- [ ] Structured logging at all levels

### Phase 5: Error Handling

- [ ] Comprehensive error types
- [ ] Cleanup guarantees
- [ ] Exit code mapping

### Phase 6: NixOS Integration

- [ ] Nix package with crane
- [ ] Shell completion installation
- [ ] NixOS module with per-backup config
- [ ] systemd service/timer generation
- [ ] Basic NixOS test

### Phase 7: Testing

- [ ] Unit tests for pure functions (UUID, path validation, etc.)
- [ ] Unit tests for business logic with mocked dependencies
- [ ] Integration tests (snapshot → backup → cleanup flow)
- [ ] Error scenario tests (lock conflicts, failures, etc.)
- [ ] Manual testing on real Btrfs filesystem

## Future Enhancements (v2+)

- [ ] Configuration file support (TOML/YAML)
- [ ] Snapshot retention policy
- [ ] Pre/post backup hooks
- [ ] Backup verification
- [ ] Metrics export (Prometheus)
- [ ] Web UI for backup status

## Appendix

### A. Example Environment File

**File**: `/etc/rustic/home-backup.env`

```bash
# Repository configuration
RUSTIC_REPOSITORY=rclone:s3:my-bucket/backups

# Authentication
RUSTIC_PASSWORD_FILE=/etc/rustic/password.txt

# Optional: rclone configuration
RCLONE_CONFIG=/etc/rclone/rclone.conf
```

**Permissions**: `0600 root:root`

### B. Example systemd Override

To customize a generated service:

```bash
systemctl edit rustic-btrfs-home-to-s3.service
```

```ini
[Service]
# Run with higher nice value (lower priority)
Nice=10

# Additional environment variables
Environment="RUST_LOG=rustic_btrfs=debug"
```

### C. Lock File Cleanup

Lock files are automatically cleaned up on process exit. For manual cleanup:

```bash
# Find stale locks (older than 24 hours)
find /run/lock/rustic-btrfs -name '*.lock' -mtime +1 -delete
```

**Note**: Only delete locks if you're certain no backup is running.

### D. Troubleshooting

**Issue**: Lock file prevents backup from running

**Solution**:

1. Check if another backup is actually running: `ps aux | grep rustic-btrfs`
2. If no process found, manually remove lock: `rm /run/lock/rustic-btrfs/<uuid>.lock`

**Issue**: Permission denied reading files

**Solution**:

1. Verify `CAP_DAC_READ_SEARCH` capability: `systemctl show rustic-btrfs-<name>.service | grep AmbientCapabilities`
2. Verify service runs as `restic` user: `systemctl show rustic-btrfs-<name>.service | grep ^User=`
3. If still failing, consider running as `root` (modify NixOS module)

**Issue**: Snapshot deletion fails

**Solution**:

1. Manually delete: `sudo btrfs subvolume delete /path/to/subvolume/.snapshot`
2. Check logs for underlying error: `journalctl -u rustic-btrfs-<name>.service`

### E. Security Considerations

1. **Capabilities**: `CAP_SYS_ADMIN` is powerful. Ensure `restic` user is isolated and dedicated.
2. **Environment files**: Store credentials in mode `0600`, owned by `root`.
3. **Network access**: Service has network access for remote repositories. Use firewall rules if needed.
4. **Snapshot exposure**: `.snapshot` is readable. Consider Btrfs quotas/permissions if multi-user.

### F. Performance Considerations

1. **Snapshot creation**: Nearly instant (COW), minimal overhead
2. **Lock file I/O**: Minimal (single file operation)
3. **rustic_core**: Performance depends on repository backend and data size
4. **Progress bar**: Minimal overhead (indicatif is efficient)

### G. Related Documentation

- [Btrfs Documentation](https://btrfs.readthedocs.io/)
- [rustic Documentation](https://rustic.cli.rs/)
- [libbtrfsutil API](https://github.com/kdave/btrfs-progs/tree/master/libbtrfsutil)
- [systemd Service Hardening](https://www.freedesktop.org/software/systemd/man/systemd.exec.html)
