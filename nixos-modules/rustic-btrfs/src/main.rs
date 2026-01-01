/// Trait definitions for testability
mod traits;

/// Btrfs operations using libbtrfsutil
mod btrfs;

/// File-based locking to prevent concurrent backups
mod lock;

/// Mock implementations for testing
#[cfg(test)]
mod mocks;

/// Main entry point
fn main() {
    println!("Hello, world!");
}
