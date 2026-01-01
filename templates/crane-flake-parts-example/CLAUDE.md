# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rust project built with Nix flakes and managed with `just` for common tasks. The project uses crane (Nix library) for building Rust packages and includes a NixOS module with systemd service/timer configuration.

## Build System

The project uses a dual build system:

- **Nix builds**: `just build` (runs `nix --no-warn-dirty --quiet --log-format raw build '.#quick-start'`) - Builds via Nix flakes using crane
- **Cargo builds**: Standard `cargo build` for development

The Nix build configuration is split across:

- `flake-module.nix` - Main flake-parts module defining packages, checks, apps, and devShells
- `nixos-module.nix` - NixOS module that creates a systemd service with timer
- `flake.nix` - Flake entry point

## Common Commands

```bash
# Build (via Nix)
just build

# Format code
just format  # Runs cargo clippy --fix and cargo fmt

# Lint
just check   # Runs cargo clippy

# Test
just test    # Runs cargo test
```

## Development Workflow

Follow Test-Driven Development (TDD):

- Write tests first before implementing functionality
- Run `just test` to verify tests fail initially
- Implement the minimal code to make tests pass
- Refactor while keeping tests green

**IMPORTANT**: Commit after EACH step completes (not at the end of all steps). This creates a clear history of the development process.

### Commit Guidelines

- Follow [Conventional Commits](https://www.conventionalcommits.org/) format
- Use scope `quick-start` for all commits
- Example: `feat(quick-start): add repository verification`, `test(restic-scrub): add integration tests`

## Linting Configuration

The project has **extremely strict** Clippy lints configured in `Cargo.toml`:

- `unwrap_used` is **denied** - never use `.unwrap()`, always handle errors properly
- Extensive restriction lints enabled as warnings (see lines 18-117 in Cargo.toml)
- Key restrictions include:
    - No `panic!`, `expect_used`, `dbg_macro`, `print_stdout`, `print_stderr`
    - No string/float arithmetic operations
    - No `unsafe` without documentation
    - Module organization: use `mod.rs` pattern (`mod_module_files` lint)
    - Comprehensive enum/struct exhaustiveness requirements

When writing or modifying code, ensure all these lint rules are followed to avoid CI failures.

## Pre-commit Hooks

The project uses pre-commit hooks (`.pre-commit-config.yaml`):

- TOML validation (`check-toml`)
- `cargo fmt` on Rust files
- `nixfmt` on Nix files (width=100)
- `markdownlint-cli2` on Markdown files (with auto-fix)

## Architecture Notes

### Nix Integration

- The project is designed to be integrated into NixOS systems via the `nixosModules.quick-start` flake output
- The systemd service is hardened with extensive security restrictions (see `nixos-module.nix:46-70`)
