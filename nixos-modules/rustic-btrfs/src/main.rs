/// Trait definitions for testability
mod traits;

/// Btrfs operations using libbtrfsutil
mod btrfs;

/// File-based locking to prevent concurrent backups
mod lock;

/// Main entry point
fn main() {
    println!("Hello, world!");
}
