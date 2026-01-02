/// Backup workflow with cleanup guarantees
use crate::traits::{BackupConfig, BackupOps, BackupStats, BtrfsOps, Error};
use std::path::Path;

/// Run the complete backup workflow with cleanup guarantees.
///
/// # Workflow
///
/// 1. Create read-only snapshot at `<subvolume>/.snapshot`
/// 2. Run backup on the snapshot
/// 3. **Always** delete snapshot (even on backup failure)
/// 4. Return backup result
///
/// # Arguments
///
/// * `btrfs` - Btrfs operations implementation
/// * `backup` - Backup operations implementation
/// * `subvolume` - Path to subvolume to backup
/// * `config` - Backup configuration
///
/// # Errors
///
/// Returns error if:
/// - Snapshot creation fails (snapshot NOT created, no cleanup needed)
/// - Backup fails (snapshot deleted, returns backup error)
///
/// # Cleanup Guarantee
///
/// Per SPEC.md section 4.2, snapshot deletion is **always** attempted,
/// even if backup fails. Snapshot deletion failures are logged as WARNING
/// but don't override the backup result.
///
/// # Example
///
/// ```ignore
/// let btrfs = LibBtrfs::new();
/// let backup = RusticBackup::new();
/// let config = BackupConfig { ... };
///
/// match run_backup_workflow(&btrfs, &backup, Path::new("/home"), &config) {
///     Ok(stats) => println!("Backup succeeded: {:?}", stats),
///     Err(e) => eprintln!("Backup failed: {:?}", e),
/// }
/// // Snapshot is guaranteed to be deleted in both cases
/// ```
pub fn run_backup_workflow<B: BtrfsOps, R: BackupOps>(
    btrfs: &B,
    backup_ops: &R,
    subvolume: &Path,
    config: &BackupConfig,
) -> Result<BackupStats, Error> {
    let snapshot_path = subvolume.join(".snapshot");

    // Step 1: Create read-only snapshot
    log::info!("Creating snapshot for subvolume: {}", subvolume.display());
    btrfs.create_snapshot(subvolume, &snapshot_path, true)?;

    // Step 2: Run backup (may succeed or fail)
    log::info!("Running backup on snapshot: {}", snapshot_path.display());
    let backup_result = backup_ops.run_backup(config);

    // Step 3: ALWAYS delete snapshot (cleanup guarantee)
    log::info!("Cleaning up snapshot: {}", snapshot_path.display());
    if let Err(e) = btrfs.delete_subvolume(&snapshot_path) {
        // Log warning but don't fail if snapshot deletion fails
        log::warn!(
            "Failed to delete snapshot {}: {}. Manual cleanup may be required.",
            snapshot_path.display(),
            match &e {
                Error::SnapshotDeletion(msg) => msg.as_str(),
                _ => "unknown error",
            }
        );
        // Continue - don't override backup_result
    }

    // Step 4: Return backup result (success or error)
    backup_result
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::mocks::{MockBackup, MockBtrfs};
    use std::path::PathBuf;

    #[test]
    fn test_workflow_success() {
        let btrfs = MockBtrfs::new();
        let backup = MockBackup::new();
        let config = BackupConfig::test_default(PathBuf::from("/test/.snapshot"));

        let result = run_backup_workflow(&btrfs, &backup, Path::new("/test"), &config);

        // Should succeed
        assert!(result.is_ok());

        // Should have created and deleted snapshot
        assert_eq!(btrfs.snapshots_created.borrow().len(), 0); // Cleaned up
        assert_eq!(btrfs.subvolumes_deleted.borrow().len(), 1);
    }

    #[test]
    fn test_workflow_backup_failure_still_cleans_up() {
        let btrfs = MockBtrfs::new();
        let mut backup = MockBackup::new();
        backup.fail_backup = true;

        let config = BackupConfig::test_default(PathBuf::from("/test/.snapshot"));

        let result = run_backup_workflow(&btrfs, &backup, Path::new("/test"), &config);

        // Should fail (backup failed)
        assert!(result.is_err());

        // Should STILL have cleaned up snapshot (cleanup guarantee)
        assert_eq!(btrfs.snapshots_created.borrow().len(), 0); // Cleaned up
        assert_eq!(btrfs.subvolumes_deleted.borrow().len(), 1);
    }

    #[test]
    fn test_workflow_snapshot_deletion_failure_returns_backup_result() {
        let mut btrfs = MockBtrfs::new();
        btrfs.fail_delete = true; // Delete will fail

        let backup = MockBackup::new(); // Backup will succeed
        let config = BackupConfig::test_default(PathBuf::from("/test/.snapshot"));

        let result = run_backup_workflow(&btrfs, &backup, Path::new("/test"), &config);

        // Should succeed (backup succeeded, even though delete failed)
        assert!(result.is_ok());

        // Snapshot deletion was attempted but failed
        assert_eq!(btrfs.snapshots_created.borrow().len(), 1); // Not cleaned up
    }

    #[test]
    fn test_workflow_snapshot_creation_failure_no_cleanup_needed() {
        let mut btrfs = MockBtrfs::new();
        btrfs.fail_snapshot = true; // Snapshot creation will fail

        let backup = MockBackup::new();
        let config = BackupConfig::test_default(PathBuf::from("/test/.snapshot"));

        let result = run_backup_workflow(&btrfs, &backup, Path::new("/test"), &config);

        // Should fail (snapshot creation failed)
        assert!(result.is_err());

        // No cleanup needed (snapshot was never created)
        assert_eq!(btrfs.snapshots_created.borrow().len(), 0);
        assert_eq!(btrfs.subvolumes_deleted.borrow().len(), 0);
    }
}
