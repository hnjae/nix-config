# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

AutoASPM is a Python-based utility that automatically enables ASPM (Active State Power Management) on PCIe devices for power saving. It's a system tool designed to run as a NixOS systemd service and uses `lspci` and `setpci` from the pciutils package to manage PCI device ASPM settings.

## Development Commands

Run these commands via the justfile:

```bash
just build           # Build the NixOS package
just check           # Run linter and type checker (ruff check, ty check)
just test            # Run pytest tests
just format          # Format code with ruff, shellharden, and shfmt
```

All development commands use `direnv exec .` to ensure proper environment setup.

## Key Architecture

### Core Classes

**ASPM Enum** (`autoaspm.py:73-106`)

- Represents the four ASPM modes: DISABLED, L0s, L1, L0sL1
- Modes are represented as bitmasks (0b00, 0b01, 0b10, 0b11)
- Methods: `from_string()` for parsing, `supports()` and `includes()` for mode compatibility checking

**PCIDevice Class** (`autoaspm.py:121-500`)

- Represents a single PCI device with ASPM support
- Core responsibilities:
    - Read PCI configuration space via `lspci -xxx`
    - Find PCIe capability offset in the configuration space
    - Read/write ASPM settings using `setpci`
    - Verify patches were applied successfully
    - Retrieve vendor:device ID for stable identification
- Key methods:
    - `get_vendor_device_id()`: Gets vendor:device ID (e.g., '8086:15b8') via `lspci -n`
    - `read_config_space()`: Caches config space bytes from lspci output
    - `find_pcie_capability()`: Locates PCIe capability in config space with circular reference detection
    - `get_link_control_offset()`: Calculates where ASPM bits are located
    - `patch_aspm(requested_mode, dry_run, strict)`: Applies ASPM changes with two modes:
        - **Safe mode** (strict=False): Uses intersection, prevents downgrade (default --mode behavior)
        - **Strict mode** (strict=True): Enforces exact mode, allows downgrade/disable (--device-mode behavior)

### Main Processing Flow

1. **Prerequisites Check** (`check_prerequisites()`): Validates Linux OS, root privileges, and pciutils availability
2. **Parse Device Overrides** (`parse_device_overrides()`): Parses --device-mode and --skip arguments, validates vendor:device format
3. **Device Discovery** (`get_aspm_devices()`): Parses `lspci -vv` output to find devices that support ASPM and extract their supported modes
4. **Device Processing** (`handle_patch_mode()` or `handle_list_mode()`):
   - Retrieves vendor:device ID for each device
   - Checks skip list
   - Applies device-specific overrides (strict mode) or default mode (safe mode)
5. **CLI Interface** (`parse_args()`, `main()`): Handles command-line options and orchestrates the flow

### Important Design Details

**Dry-Run by Default**: Running with `--mode` only performs a dry-run. Use `--run` to actually patch devices. This is a safety feature.

**Device Identification**: Vendor:Device ID (e.g., `8086:15b8`) is used instead of PCI address for device-specific configuration. This is more stable across hardware changes (e.g., adding/removing PCIe cards, BIOS changes).

**Two-Mode System**:

1. **Safe Mode** (--mode, strict=False):
   - Uses intersection of requested and supported modes
   - Only allows upgrades (target must include current state)
   - Never downgrades (L0sL1 → L1 is skipped)
   - Never allows lateral changes (L0s ↔ L1 is skipped)
   - Cannot disable ASPM
   - Appropriate for system-wide default settings

2. **Strict Mode** (--device-mode, strict=True):
   - Enforces exact requested mode
   - Allows downgrade (L0sL1 → L1 is applied)
   - Allows disable (can set to DISABLED)
   - Fails if device doesn't support exact mode
   - Appropriate for device-specific overrides

**Priority Order**:

1. `--skip` devices are not touched at all
2. `--device-mode` overrides use strict mode
3. `--mode` default uses safe mode
4. No `--mode` uses maximum supported per device

**PCI Configuration Space Parsing**:

- Configuration space is 256 bytes
- Capabilities are found via a linked list starting at offset 0x34
- PCIe capability is identified by ID 0x10
- ASPM bits are at offset 0x10 within the PCIe capability (lower 2 bits)
- Uses regex to parse `lspci` output since raw config space access requires special permissions

**Error Handling**:

- `CapabilityNotFoundError`: Device doesn't have PCIe capability
- `DeviceAccessError`: Failed to read/write device via lspci/setpci
- Errors are logged but don't stop processing other devices

## PCI Details (for Reference)

- PCI_CAP_ID_PCIE = 0x10 (PCIe capability identifier)
- PCIE_CAP_LINK_CONTROL_OFFSET = 0x10 (Link Control Register offset within PCIe capability)
- PCI_CAPABILITY_LIST_POINTER = 0x34 (Capabilities pointer location in config space)
- MAX_CAPABILITY_SEARCH_ITERATIONS = 48 (Safety limit to prevent infinite loops)

## Code Style & Linting

- Ruff is configured with all rules enabled except specific exceptions (see pyproject.toml)
- Line length: 79 characters
- Docstring convention: PEP 257
- Test files excluded from basedpyright type checking (basedpyright config in pyproject.toml)
- Tests can use assertions, access private members, and don't need full type annotations

## Git Commits

Follow Conventional Commits format with `autoaspm` as the scope. **IMPORTANT: Create commits after each major step, NOT at the end of all tasks.** This provides better git history and allows easier rollback if needed.

Format: `<type>(autoaspm): <description>`

Common types:

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `test`: Test additions or changes
- `docs`: Documentation updates
- `style`: Code style changes (formatting, linting)
- `chore`: Build, dependencies, or maintenance tasks

### Commit Strategy

**Multi-step features should be committed incrementally:**

For example, when implementing vendor:device ID based ASPM configuration:

1. `feat(autoaspm): add vendor:device ID retrieval to PCIDevice` - After adding the ID retrieval method
2. `feat(autoaspm): add --device-mode and --skip CLI flags` - After CLI parsing is complete
3. `feat(autoaspm): add strict mode for explicit ASPM control` - After implementing strict mode
4. `feat(autoaspm): implement device-specific ASPM overrides` - After handle_patch_mode is updated
5. `feat(autoaspm): wire up device override logic in main` - After main() integration
6. `test(autoaspm): add tests for vendor:device ID and overrides` - After tests are written
7. `feat(autoaspm): add deviceModes and skipDevices to NixOS module` - After module update
8. `docs(autoaspm): update documentation for device overrides` - After documentation

**Single-step changes can be committed immediately:**

- `fix(autoaspm): handle missing PCIe capability gracefully`
- `style(autoaspm): fix ruff linting issues`
- `refactor(autoaspm): extract PCI config parsing into helper method`

### TDD + Incremental Commits

**CRITICAL: Commit after EACH step is completed, NOT at the end of all steps.**

When following TDD (Test-Driven Development), create a commit immediately after completing each step:

**Workflow:**

1. **Write failing tests** → **Commit immediately**
   - Write tests for the feature
   - Run tests to verify they fail
   - Commit: `test(autoaspm): add tests for <feature>`

2. **Implement feature** → **Commit immediately**
   - Write minimal code to make tests pass
   - Run tests to verify they pass
   - Fix any linter/type errors
   - Commit: `feat(autoaspm): implement <feature>`

3. **Refactor (optional)** → **Commit immediately**
   - Improve implementation while keeping tests passing
   - Commit: `refactor(autoaspm): improve <feature> implementation`

4. **Update documentation (if needed)** → **Commit immediately**
   - Update CLAUDE.md, help messages, etc.
   - Commit: `docs(autoaspm): document <feature>`

**Example: Adding lateral change prevention**

1. Write 4 tests for lateral change prevention
   - Run `just test` to see them fail
   - **→ Commit: `test(autoaspm): add tests for lateral ASPM change prevention`**

2. Implement lateral change check in patch_aspm()
   - Run `just test` to verify tests pass
   - Fix linter errors (add noqa comment)
   - **→ Commit: `feat(autoaspm): prevent lateral ASPM changes in safe mode`**

3. Update CLAUDE.md and help message
   - **→ Commit: `docs(autoaspm): document lateral change prevention`**

**DO NOT:**

- ❌ Complete all steps first, then create multiple commits at the end
- ❌ Batch unrelated changes into one large commit
- ❌ Wait until "everything is done" to commit

**DO:**

- ✅ Commit immediately after each major step
- ✅ Create focused, single-purpose commits
- ✅ Commit even if more work remains

This approach gives you:

- Clear test/implementation separation in git history
- Easy rollback of any specific step without losing others
- Documentation of what was tested vs what was implemented
- Better progress tracking during development

### Benefits of Incremental Commits

- **Better git history**: Each commit has a clear, focused purpose
- **Easier code review**: Changes can be reviewed step-by-step
- **Safer rollback**: Can revert specific steps without losing entire feature
- **Clearer progress tracking**: Shows incremental progress during implementation

## NixOS Integration

The module at `module.nix` configures AutoASPM as a systemd service:

- Service type: oneshot (runs once at startup)
- Depends on: systemd-udev-settle.service
- Security hardening: strict filesystem protection, no network, restricted syscalls
- Device access: PrivateDevices = false to allow PCI device access

**Module Options**:

- `mode`: Default ASPM mode for all devices (safe mode)
- `deviceModes`: Attribute set of vendor:device → mode mappings (strict mode)
- `skipDevices`: List of vendor:device IDs to skip entirely

**Example Configuration**:

```nix
services.autoaspm = {
  enable = true;
  mode = "l1";                          # Default for all devices
  deviceModes = {
    "8086:15b8" = "l0sl1";              # Intel WiFi uses L0sL1
    "10de:1234" = "disabled";           # NVIDIA GPU disabled
  };
  skipDevices = [ "8086:9999" ];        # Skip this device
};
```

The module dynamically builds the command line:
`--run --mode l1 --device-mode 8086:15b8=l0sl1 --device-mode 10de:1234=disabled --skip 8086:9999`

## Testing

Tests in `test_autoaspm.py` use mocking to avoid requiring actual PCI devices:

- Mock `subprocess.run` to simulate lspci/setpci output
- Test ASPM enum logic, mode negotiation, configuration space parsing
- Test error conditions: missing capabilities, invalid device access, timeout scenarios
- Test vendor:device ID retrieval and caching
- Test device override parsing and validation
- Test strict vs safe mode behavior
- 63 tests total covering all major functionality

### Test-Driven Development (TDD)

**IMPORTANT: Follow TDD approach for new features.**

1. **Write tests first**, then implement the feature
2. Run tests to see them fail (Red)
3. Implement minimal code to make tests pass (Green)
4. Refactor code while keeping tests passing (Refactor)

#### TDD Workflow Example

When adding a new feature (e.g., device filtering by name):

```python
# Step 1: Write failing tests first
class TestDeviceFiltering:
    def test_filter_by_device_name(self):
        devices = [...]
        filtered = filter_devices_by_name(devices, "Intel")
        assert len(filtered) == expected_count

    def test_filter_invalid_pattern(self):
        with pytest.raises(ValueError):
            filter_devices_by_name(devices, "[invalid")

# Step 2: Run tests - they should fail
# just test

# Step 3: Implement minimal code to pass tests
def filter_devices_by_name(devices, pattern):
    # Implementation here
    pass

# Step 4: Run tests - they should pass
# just test

# Step 5: Refactor if needed, tests still pass
```

#### Benefits of TDD

- **Better design**: Writing tests first forces you to think about the API
- **Fewer bugs**: Edge cases are considered upfront
- **Refactoring confidence**: Tests ensure changes don't break functionality
- **Living documentation**: Tests show how the code is meant to be used

#### When to Skip TDD

TDD is strongly recommended for all features, but may be skipped for:

- Quick bug fixes where the bug itself serves as the test case
- Exploratory code that will be thrown away
- Code that's difficult to test in isolation (should be rare with good design)
