# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rust project (edition 2024) built with Nix flakes and managed with `just` for common tasks. The project uses crane (Nix library) for building Rust packages and includes a NixOS module with systemd service/timer configuration.

**Important**: This repository contains a flake-parts module (`flake-module.nix`), not a standalone flake. It's designed to be imported into a larger flake-parts-based configuration.

## Build System

**Important**: Always use `just` commands or the Nix develop environment for builds and tests. Never run `cargo build` or `cargo test` directly - use `just build` and `just test` instead.

The project uses a dual build system:

- **Cargo builds**: `just build` (runs `cargo build` in Nix develop environment) - Fast iterative development
- **Nix builds**: `just build-nix` (runs `nix build '.#rustic-btrfs'`) - Reproducible package builds via crane

The Nix build configuration is split across:

- `flake-module.nix` - Main flake-parts module defining packages, checks, apps, and devShells
- `nixos-module.nix` - NixOS module that creates a systemd service with timer

## Common Commands

```sh
# Build (via Cargo in Nix environment)
just build

# Build (via Nix flakes)
just build-nix

# Format code
just format  # Runs cargo clippy --fix and cargo fmt

# Lint
just check   # Runs cargo clippy

# Test (library unit tests in Nix environment)
just test    # Runs cargo test --lib in Nix develop
```

## Development Workflow

This project combines **Spec-Driven Development (SDD)** and **Test-Driven Development (TDD)**:

### Spec-Driven Development (SDD)

- Write specifications in `SPEC.md` before implementing features
- Specifications define:
    - What features/functionality will be built
    - API interfaces and contracts
    - Expected behavior and requirements
    - Acceptance criteria

### Test-Driven Development (TDD)

- Write tests first based on the specification
- Run `just test` to verify tests fail initially (Red)
    - **Important**: Always use `just test`, never `cargo test` directly
- Implement the minimal code to make tests pass (Green)
- Refactor while keeping tests green (Refactor)

### Combined Workflow

1. Write specification in `SPEC.md` (defines "what to build")
2. Write failing tests based on spec (defines "how to verify")
3. Implement code to pass tests (fulfills the spec)
4. Refactor while maintaining spec compliance and test coverage

**IMPORTANT**: Commit after EACH step completes (not at the end of all steps). This creates a clear history of the development process.

### Commit Guidelines

- Follow [Conventional Commits](https://www.conventionalcommits.org/) format
- Use scope `rustic-btrfs` for all commits
- Example: `feat(rustic-btrfs): add repository verification`, `test(rustic-btrfs): add integration tests`

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

- `cargo fmt` on Rust files
- `check-toml` for TOML file validation

The project uses rustfmt with `style_edition = "2024"` (configured in `.rustfmt.toml`).

## Architecture Notes

### Nix Integration

- The project is designed to be integrated into NixOS systems via the `nixosModules.rustic-btrfs` flake output
- `flake-module.nix`: Flake-parts module that exports:
    - `packages.rustic-btrfs`: The compiled binary built with crane
    - `checks.rustic-btrfs`: Build validation (runs during `nix flake check`)
    - `apps.rustic-btrfs`: Application runner
    - `devShells.rustic-btrfs`: Development environment with cargo-tarpaulin and rust-analyzer
    - `nixosModules.rustic-btrfs`: The NixOS module
- `nixos-module.nix`: NixOS module that creates:
    - A systemd oneshot service with hardened security settings
    - A systemd timer (runs yearly with 5m randomized delay)
    - Configuration option: `my.services.rustic-btrfs.enable`
    - The service is highly restricted: no network, private mounts, protected kernel access

### Supported Platforms

Only Linux platforms are supported:

- `x86_64-linux`
- `aarch64-linux`
