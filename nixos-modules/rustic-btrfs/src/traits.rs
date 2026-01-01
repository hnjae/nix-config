use std::path::Path;

/// Error type for rustic-btrfs operations.
/// Will be expanded with specific error variants during implementation.
#[derive(Debug)]
pub enum Error {
    /// Btrfs operation error
    BtrfsError(String),
    /// Backup operation error
    BackupError(String),
    /// I/O error
    IoError(std::io::Error),
    /// Other error
    Other(String),
}

impl From<std::io::Error> for Error {
    fn from(error: std::io::Error) -> Self {
        Self::IoError(error)
    }
}

/// Configuration for backup operation.
/// Will be expanded with specific fields during implementation.
#[derive(Debug)]
pub struct BackupConfig {
    /// Snapshot path to backup from
    pub snapshot_path: std::path::PathBuf,
    /// Optional glob patterns for partial backup
    pub glob_patterns: Option<Vec<String>>,
    /// Optional as-path for repository storage
    pub as_path: Option<String>,
    /// Backup description
    pub description: Option<String>,
    /// Snapshot timestamp
    pub timestamp: Option<String>,
}

/// Statistics from backup operation.
/// Will be expanded with specific fields during implementation.
#[derive(Debug)]
pub struct BackupStats {
    /// Number of files processed
    pub files_processed: u64,
    /// Bytes processed
    pub bytes_processed: u64,
}

/// Trait for Btrfs operations.
/// Enables testing by allowing mock implementations.
pub trait BtrfsOps {
    /// Get the UUID of a Btrfs subvolume.
    ///
    /// # Errors
    ///
    /// Returns error if path is not a Btrfs subvolume or UUID cannot be retrieved.
    fn get_subvolume_uuid(&self, path: &Path) -> Result<String, Error>;

    /// Check if a path is a Btrfs subvolume.
    ///
    /// # Errors
    ///
    /// Returns error if the check cannot be performed.
    fn is_subvolume(&self, path: &Path) -> Result<bool, Error>;

    /// Create a read-only snapshot of a Btrfs subvolume.
    ///
    /// # Errors
    ///
    /// Returns error if snapshot creation fails.
    fn create_snapshot(&self, source: &Path, dest: &Path, readonly: bool) -> Result<(), Error>;

    /// Delete a Btrfs subvolume.
    ///
    /// # Errors
    ///
    /// Returns error if deletion fails.
    fn delete_subvolume(&self, path: &Path) -> Result<(), Error>;
}

/// Trait for backup operations.
/// Enables testing by allowing mock implementations.
pub trait BackupOps {
    /// Run a backup operation with the given configuration.
    ///
    /// # Errors
    ///
    /// Returns error if backup fails.
    fn run_backup(&self, config: &BackupConfig) -> Result<BackupStats, Error>;
}
