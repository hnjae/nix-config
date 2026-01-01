/// rustic-btrfs library
///
/// Provides modules for backing up Btrfs subvolumes using rustic.
// Public modules
pub mod backup;
pub mod btrfs;
pub mod cli;
pub mod lock;
pub mod logging;
pub mod mocks; // Always available for integration tests
pub mod progress;
pub mod traits;
pub mod workflow;
