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
#[derive(Debug, Clone)]
pub struct BackupConfig {
    /// Snapshot path to backup from
    pub snapshot_path: std::path::PathBuf,

    /// Optional glob patterns for partial backup (from --paths)
    pub glob_patterns: Option<Vec<String>>,

    /// Optional as-path for repository storage
    pub as_path: Option<String>,

    /// Backup description
    pub description: Option<String>,

    /// Snapshot timestamp (ISO 8601)
    pub timestamp: Option<String>,

    // Parent processing options
    /// Group snapshots by criterion (default: host,paths)
    pub group_by: Option<String>,

    /// Specific parent snapshot
    pub parent: Option<String>,

    /// Skip backup if unchanged vs parent
    pub skip_if_unchanged: bool,

    /// No parent, read all files
    pub force: bool,

    /// Ignore ctime changes
    pub ignore_ctime: bool,

    /// Ignore inode changes
    pub ignore_inode: bool,

    // Exclude options
    /// Additional glob patterns (from --glob)
    pub extra_globs: Option<Vec<String>>,

    /// Case-insensitive glob patterns
    pub iglobs: Option<Vec<String>>,

    /// Read glob patterns from file
    pub glob_file: Option<std::path::PathBuf>,

    /// Read case-insensitive glob patterns from file
    pub iglob_file: Option<std::path::PathBuf>,

    /// Use .gitignore rules
    pub git_ignore: bool,

    /// Don't require git repo for git-ignore
    pub no_require_git: bool,

    /// Treat file as .gitignore
    pub custom_ignorefile: Option<std::path::PathBuf>,

    /// Exclude directories containing this file
    pub exclude_if_present: Option<std::path::PathBuf>,

    /// Exclude files larger than size
    pub exclude_larger_than: Option<String>,

    // Snapshot metadata
    /// Label for snapshot
    pub label: Option<String>,

    /// Tags for snapshot
    pub tags: Option<Vec<String>>,

    /// Mark snapshot as uneraseable
    pub delete_never: bool,

    /// Auto-delete snapshot after duration
    pub delete_after: Option<String>,

    /// Override hostname
    pub host: Option<String>,

    /// Dry-run mode
    pub dry_run: bool,
}

impl BackupConfig {
    /// Create a minimal test configuration
    #[cfg(test)]
    #[must_use]
    pub fn test_default(snapshot_path: std::path::PathBuf) -> Self {
        Self {
            snapshot_path,
            glob_patterns: None,
            as_path: None,
            description: None,
            timestamp: None,
            group_by: None,
            parent: None,
            skip_if_unchanged: false,
            force: false,
            ignore_ctime: false,
            ignore_inode: false,
            extra_globs: None,
            iglobs: None,
            glob_file: None,
            iglob_file: None,
            git_ignore: false,
            no_require_git: false,
            custom_ignorefile: None,
            exclude_if_present: None,
            exclude_larger_than: None,
            label: None,
            tags: None,
            delete_never: false,
            delete_after: None,
            host: None,
            dry_run: false,
        }
    }
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
