/// Trait definitions for testability
mod traits;

/// Btrfs operations using libbtrfsutil
mod btrfs;

/// File-based locking to prevent concurrent backups
mod lock;

/// Backup operations using rustic_core
mod backup;

/// Command-line interface
mod cli;

/// Mock implementations for testing
#[cfg(test)]
mod mocks;

/// Main entry point
fn main() {
    println!("Hello, world!");
}
