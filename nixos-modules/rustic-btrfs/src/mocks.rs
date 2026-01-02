/// Mock implementations for testing
use crate::traits::{BackupConfig, BackupOps, BackupStats, BtrfsOps, Error};
use std::cell::RefCell;
use std::path::{Path, PathBuf};

/// Mock implementation of `BtrfsOps` for testing.
/// Tracks operations and allows configurable failures.
#[derive(Debug)]
pub struct MockBtrfs {
    /// If true, snapshot creation will fail
    pub fail_snapshot: bool,
    /// If true, snapshot deletion will fail
    pub fail_delete: bool,
    /// If true, UUID retrieval will fail
    pub fail_uuid: bool,
    /// If true, `is_subvolume` check will fail
    pub fail_is_subvolume: bool,
    /// If true, `is_subvolume` returns true
    pub return_is_subvolume: bool,
    /// Snapshots that have been created (source, dest pairs)
    pub snapshots_created: RefCell<Vec<(PathBuf, PathBuf)>>,
    /// Subvolumes that have been deleted
    pub subvolumes_deleted: RefCell<Vec<PathBuf>>,
    /// UUIDs requested
    pub uuids_requested: RefCell<Vec<PathBuf>>,
    /// Fake UUID to return
    pub fake_uuid: String,
}

impl MockBtrfs {
    /// Create a new `MockBtrfs` with default settings.
    #[must_use]
    pub fn new() -> Self {
        Self {
            fail_snapshot: false,
            fail_delete: false,
            fail_uuid: false,
            fail_is_subvolume: false,
            return_is_subvolume: true,
            snapshots_created: RefCell::new(Vec::new()),
            subvolumes_deleted: RefCell::new(Vec::new()),
            uuids_requested: RefCell::new(Vec::new()),
            fake_uuid: "5ea01852-b4f9-4e4a-9c9d-f9c8b7a6e5d4".to_owned(),
        }
    }

    /// Check if a snapshot was created.
    #[must_use]
    pub fn snapshot_created(&self, source: &Path, dest: &Path) -> bool {
        self.snapshots_created
            .borrow()
            .iter()
            .any(|(s, d)| s == source && d == dest)
    }

    /// Check if a subvolume was deleted.
    #[must_use]
    pub fn subvolume_deleted(&self, path: &Path) -> bool {
        self.subvolumes_deleted.borrow().iter().any(|p| p == path)
    }
}

impl Default for MockBtrfs {
    fn default() -> Self {
        Self::new()
    }
}

impl BtrfsOps for MockBtrfs {
    fn get_subvolume_uuid(&self, path: &Path) -> Result<String, Error> {
        self.uuids_requested.borrow_mut().push(path.to_path_buf());

        if self.fail_uuid {
            return Err(Error::Btrfs("Mock UUID retrieval failed".to_owned()));
        }

        Ok(self.fake_uuid.clone())
    }

    fn is_subvolume(&self, _path: &Path) -> Result<bool, Error> {
        if self.fail_is_subvolume {
            return Err(Error::Btrfs("Mock is_subvolume check failed".to_owned()));
        }

        Ok(self.return_is_subvolume)
    }

    fn create_snapshot(&self, source: &Path, dest: &Path, _readonly: bool) -> Result<(), Error> {
        if self.fail_snapshot {
            return Err(Error::Btrfs("Mock snapshot creation failed".to_owned()));
        }

        self.snapshots_created
            .borrow_mut()
            .push((source.to_path_buf(), dest.to_path_buf()));
        Ok(())
    }

    fn delete_subvolume(&self, path: &Path) -> Result<(), Error> {
        if self.fail_delete {
            return Err(Error::SnapshotDeletion(
                "Mock subvolume deletion failed".to_owned(),
            ));
        }

        self.subvolumes_deleted
            .borrow_mut()
            .push(path.to_path_buf());

        // Remove from snapshots_created if it was a snapshot
        self.snapshots_created
            .borrow_mut()
            .retain(|(_, dest)| dest != path);

        Ok(())
    }
}

/// Mock implementation of `BackupOps` for testing.
/// Tracks operations and allows configurable failures.
#[derive(Debug)]
pub struct MockBackup {
    /// If true, backup will fail
    pub fail_backup: bool,
    /// Backups that have been run
    pub backups_run: RefCell<Vec<BackupConfig>>,
    /// Fake backup stats to return
    pub fake_stats: BackupStats,
}

impl MockBackup {
    /// Create a new `MockBackup` with default settings.
    #[must_use]
    pub const fn new() -> Self {
        Self {
            fail_backup: false,
            backups_run: RefCell::new(Vec::new()),
            fake_stats: BackupStats {
                files_processed: 100,
                bytes_processed: 1024 * 1024,
            },
        }
    }

    /// Check how many backups were run.
    #[must_use]
    pub fn backup_count(&self) -> usize {
        self.backups_run.borrow().len()
    }
}

impl Default for MockBackup {
    fn default() -> Self {
        Self::new()
    }
}

impl BackupOps for MockBackup {
    fn run_backup(&self, config: &BackupConfig) -> Result<BackupStats, Error> {
        if self.fail_backup {
            return Err(Error::Backup {
                message: "Mock backup failed".to_owned(),
                exit_code: None,
            });
        }

        self.backups_run.borrow_mut().push(config.clone());

        Ok(BackupStats {
            files_processed: self.fake_stats.files_processed,
            bytes_processed: self.fake_stats.bytes_processed,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_mock_btrfs_default() {
        let mock = MockBtrfs::new();
        assert!(!mock.fail_snapshot);
        assert!(!mock.fail_delete);
        assert_eq!(mock.snapshots_created.borrow().len(), 0);
    }

    #[test]
    fn test_mock_btrfs_uuid() {
        let mock = MockBtrfs::new();
        let uuid = mock.get_subvolume_uuid(Path::new("/test")).ok();
        assert!(uuid.is_some());
        assert_eq!(
            uuid,
            Some("5ea01852-b4f9-4e4a-9c9d-f9c8b7a6e5d4".to_string())
        );
    }

    #[test]
    fn test_mock_btrfs_snapshot() {
        let mock = MockBtrfs::new();
        let result = mock.create_snapshot(Path::new("/src"), Path::new("/dst"), true);
        assert!(result.is_ok());
        assert!(mock.snapshot_created(Path::new("/src"), Path::new("/dst")));
    }

    #[test]
    fn test_mock_btrfs_snapshot_failure() {
        let mut mock = MockBtrfs::new();
        mock.fail_snapshot = true;
        let result = mock.create_snapshot(Path::new("/src"), Path::new("/dst"), true);
        assert!(result.is_err());
    }

    #[test]
    fn test_mock_backup_default() {
        let mock = MockBackup::new();
        assert!(!mock.fail_backup);
        assert_eq!(mock.backup_count(), 0);
    }

    #[test]
    fn test_mock_backup_run() {
        let mock = MockBackup::new();
        let config = BackupConfig::test_default(PathBuf::from("/test/.snapshot"));
        let result = mock.run_backup(&config);
        assert!(result.is_ok());
        assert_eq!(mock.backup_count(), 1);
    }

    #[test]
    fn test_mock_backup_failure() {
        let mut mock = MockBackup::new();
        mock.fail_backup = true;
        let config = BackupConfig::test_default(PathBuf::from("/test/.snapshot"));
        let result = mock.run_backup(&config);
        assert!(result.is_err());
    }
}
