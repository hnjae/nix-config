/// Backup operations using rustic_core
use crate::traits::{BackupConfig, BackupOps, BackupStats, Error};

/// Production implementation of BackupOps using rustic_core.
pub struct RusticBackup;

impl RusticBackup {
    /// Create a new RusticBackup instance.
    #[must_use]
    pub const fn new() -> Self {
        Self
    }
}

impl Default for RusticBackup {
    fn default() -> Self {
        Self::new()
    }
}

impl BackupOps for RusticBackup {
    fn run_backup(&self, config: &BackupConfig) -> Result<BackupStats, Error> {
        log::debug!("Starting backup with config: {:?}", config.snapshot_path);
        log::debug!("Glob patterns: {:?}", config.glob_patterns);
        log::debug!("As-path: {:?}", config.as_path);
        log::debug!("Description: {:?}", config.description);
        log::debug!("Timestamp: {:?}", config.timestamp);

        // TODO: Implement using rustic_core
        //
        // This will involve:
        // 1. Creating a Repository from environment variables / config
        // 2. Opening the repository with password
        // 3. Creating a backup with:
        //    - Source: config.snapshot_path
        //    - Glob patterns: config.glob_patterns (if partial backup)
        //    - As-path: config.as_path
        //    - Description: config.description
        //    - Timestamp: config.timestamp
        //    - Fixed flags: --no-scan, --one-file-system, --ignore-devid
        // 4. Collecting statistics (files processed, bytes processed)
        //
        // Example structure:
        // let repo = Repository::from_env()?;
        // let backup_opts = BackupOptions {
        //     source: config.snapshot_path,
        //     glob: config.glob_patterns,
        //     as_path: config.as_path,
        //     description: config.description,
        //     time: config.timestamp,
        //     no_scan: true,
        //     one_file_system: true,
        //     ignore_devid: true,
        //     ..Default::default()
        // };
        // let result = repo.backup(&backup_opts)?;
        // Ok(BackupStats {
        //     files_processed: result.files_new + result.files_changed + result.files_unmodified,
        //     bytes_processed: result.data_added,
        // })

        log::error!("rustic_core integration not implemented yet");
        Err(Error::BackupError {
            message: "rustic_core integration not implemented yet".to_string(),
            exit_code: None,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[test]
    fn test_rustic_backup_new() {
        let backup = RusticBackup::new();
        let config = BackupConfig {
            snapshot_path: PathBuf::from("/test/.snapshot"),
            glob_patterns: None,
            as_path: None,
            description: None,
            timestamp: None,
        };

        // Currently returns error since not implemented
        let result = backup.run_backup(&config);
        assert!(result.is_err());
    }
}
