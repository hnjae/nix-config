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
    fn run_backup(&self, _config: &BackupConfig) -> Result<BackupStats, Error> {
        // NOTE: This is a placeholder implementation.
        // The rustic_core API in version 0.3 may differ from what we expected.
        // For now, return an informative error.
        //
        // TODO: Update this implementation once we verify the exact rustic_core 0.3 API.
        // The implementation should:
        // 1. Configure and open repository from environment variables
        // 2. Build backup options with all parameters from BackupConfig
        // 3. Create local source with globs and excludes
        // 4. Run the backup
        // 5. Collect and return statistics

        log::error!("rustic_core 0.3 integration requires API verification");
        log::error!("Please refer to rustic_core documentation for the correct API");

        Err(Error::BackupError {
            message: "rustic_core integration requires API update for version 0.3".to_string(),
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
        let config = BackupConfig::test_default(PathBuf::from("/test/.snapshot"));

        // Returns error - placeholder implementation
        let result = backup.run_backup(&config);
        assert!(result.is_err());

        // Verify it's a backup error
        match result {
            Err(Error::BackupError { .. }) => {} // Expected (placeholder)
            Err(e) => panic!("Expected BackupError, got: {:?}", e),
            Ok(_) => panic!("Expected error, got success"),
        }
    }
}
