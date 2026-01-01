use std::path::Path;

/// Error type for rustic-btrfs operations with exit code mapping.
#[derive(Debug)]
pub enum Error {
    /// Lock acquisition failed (another backup running)
    /// Exit code: 1
    LockError(String),

    /// Snapshot conflict: .snapshot exists but is not a subvolume
    /// Exit code: 1
    SnapshotConflict(String),

    /// Snapshot creation failed
    /// Exit code: 1
    SnapshotCreation(String),

    /// Snapshot deletion failed
    /// Exit code: depends on context (see cleanup guarantees)
    SnapshotDeletion(String),

    /// Btrfs operation error
    /// Exit code: 1
    BtrfsError(String),

    /// Backup operation error
    /// Exit code: configurable (rustic_core error code)
    BackupError {
        /// Error message
        message: String,
        /// Exit code from rustic_core (if available)
        exit_code: Option<i32>,
    },

    /// I/O error
    /// Exit code: 1
    IoError(std::io::Error),

    /// Configuration error
    /// Exit code: 1
    ConfigError(String),

    /// Other error
    /// Exit code: 1
    Other(String),
}

impl Error {
    /// Get the exit code for this error.
    ///
    /// # Returns
    ///
    /// Exit code as specified in SPEC.md section 4.1:
    /// - General errors: 1
    /// - Backup errors: rustic_core error code (or 1 if not available)
    #[must_use]
    pub fn exit_code(&self) -> i32 {
        match self {
            Self::BackupError { exit_code, .. } => exit_code.unwrap_or(1),
            Self::LockError(_)
            | Self::SnapshotConflict(_)
            | Self::SnapshotCreation(_)
            | Self::SnapshotDeletion(_)
            | Self::BtrfsError(_)
            | Self::IoError(_)
            | Self::ConfigError(_)
            | Self::Other(_) => 1,
        }
    }
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_error_exit_code_general_errors() {
        // General errors should return exit code 1
        assert_eq!(Error::LockError("test".to_string()).exit_code(), 1);
        assert_eq!(Error::SnapshotConflict("test".to_string()).exit_code(), 1);
        assert_eq!(Error::SnapshotCreation("test".to_string()).exit_code(), 1);
        assert_eq!(Error::SnapshotDeletion("test".to_string()).exit_code(), 1);
        assert_eq!(Error::BtrfsError("test".to_string()).exit_code(), 1);
        assert_eq!(Error::ConfigError("test".to_string()).exit_code(), 1);
        assert_eq!(Error::Other("test".to_string()).exit_code(), 1);
    }

    #[test]
    fn test_error_exit_code_backup_error_default() {
        // Backup error without exit code should return 1
        let error = Error::BackupError {
            message: "test".to_string(),
            exit_code: None,
        };
        assert_eq!(error.exit_code(), 1);
    }

    #[test]
    fn test_error_exit_code_backup_error_custom() {
        // Backup error with custom exit code should return that code
        let error = Error::BackupError {
            message: "test".to_string(),
            exit_code: Some(42),
        };
        assert_eq!(error.exit_code(), 42);
    }

    #[test]
    fn test_error_from_io_error() {
        // IoError should convert from std::io::Error
        let io_err = std::io::Error::new(std::io::ErrorKind::NotFound, "test");
        let error = Error::from(io_err);
        assert_eq!(error.exit_code(), 1);
    }
}
