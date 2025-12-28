# wincompat-rename

※ Written by LLM (claude-code Sonnet 4.5)

CLI tool to rename files to Windows-compatible names on Linux/Unix systems.

## Features

- Converts Windows illegal characters to full-width equivalents
- Handles Windows reserved names (CON, PRN, AUX, NUL, COM1-9, LPT1-9)
- Removes trailing spaces and converts trailing dots
- Recursive directory traversal
- Dry-run mode to preview changes
- Collision detection and safe operation
- Protection for dangerous system paths
- Filesystem boundary detection
- Color-coded output with progress bar

## Installation

### Using Cargo

```bash
cargo install --path .
```

### Using Nix

```bash
nix-build
```

Or add to your Nix configuration:

```nix
{
  environment.systemPackages = [
    (pkgs.callPackage ./path/to/wincompat-rename { })
  ];
}
```

## Usage

```
wincompat-rename [OPTIONS] <PATH>...

Arguments:
  <PATH>...    Files or directories to process

Options:
  -r, --recursive              Recursively traverse directories
  -n, --dry-run                Show changes without actually renaming
  -H, --hidden                 Include hidden files (starting with .)
      --process-dangerous-files Process dangerous paths
  -h, --help                   Print help information
  -V, --version                Print version information
```

## Examples

### Basic usage

```bash
# Rename a single file
wincompat-rename "file:name.txt"
# Output: file:name.txt → file：name.txt

# Rename multiple files
wincompat-rename file1.txt file2.txt file3.txt
```

### Recursive directory processing

```bash
# Process all files in directory recursively
wincompat-rename -r /path/to/directory
```

### Preview changes with dry-run

```bash
# See what would be changed without actually renaming
wincompat-rename -n -r /path/to/directory
```

### Include hidden files

```bash
# Process hidden files as well
wincompat-rename -r -H /path/to/directory
```

## Conversion Rules

### 1. Windows Illegal Characters

The following half-width characters are converted to full-width:

- `\` → `＼`
- `/` → `／`
- `:` → `：`
- `*` → `＊`
- `?` → `？`
- `"` → `＂`
- `<` → `＜`
- `>` → `＞`
- `|` → `｜`

Note: `%` is not converted.

### 2. Trailing Spaces and Dots

- **Trailing spaces**: Removed (`"file   "` → `"file"`)
- **Trailing dots**: Last dot converted to full-width (`"file."` → `"file．"`)

### 3. Windows Reserved Names

Reserved names get an underscore appended (case-insensitive):

- `CON`, `PRN`, `AUX`, `NUL`
- `COM1` through `COM9`
- `LPT1` through `LPT9`

Examples:

- `CON` → `CON_`
- `CON.txt` → `CON_.txt`
- `con.TXT` → `con_.TXT`

### 4. Conversion Order

For complex cases, conversions happen in this order:

1. Reserved name handling
2. Illegal character conversion
3. Trailing space removal
4. Trailing dot conversion

## Safety Features

### Dangerous Paths

By default, the following paths are skipped (use `--process-dangerous-files` to override):

1. **All dotfiles/dotdirs directly under $HOME**
   - `.config`, `.local`, `.cache`, etc.

2. **Specific directory names anywhere**:
   - `.config`, `.git`, `.ssh`, `.snapshots`
   - `__pycache__`, `.direnv`, `.venv`
   - `.ansible`, `.husky`, `.github`
   - `.git-crypt`, `.vscode`, `node_modules`

3. **Cache directories** marked with `CACHEDIR.TAG`

### Collision Detection

If a renamed file would overwrite an existing file, the operation is skipped with a warning.

### Filesystem Boundaries

The tool respects filesystem boundaries and won't follow mounts to different filesystems (similar to `--one-file-system`).

### Symlinks

Symlinks are never renamed and are not followed during traversal.


## Testing

Run the test suite:

```bash
# Unit tests
cargo test --lib

# Integration tests
cargo test --test integration_tests

# All tests
cargo test
```
