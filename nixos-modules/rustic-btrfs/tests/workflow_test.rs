/// Integration tests for backup workflow
///
/// Tests the complete snapshot → backup → cleanup flow using mocked dependencies
use rustic_btrfs::mocks::{MockBackup, MockBtrfs};
use rustic_btrfs::traits::{BackupConfig, BtrfsOps};
use rustic_btrfs::workflow::run_backup_workflow;
use std::path::PathBuf;

/// Create a minimal test BackupConfig
fn test_config(snapshot_path: PathBuf) -> BackupConfig {
    BackupConfig {
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

#[test]
fn test_successful_backup_workflow() {
    // Arrange
    let btrfs = MockBtrfs::new();
    let backup = MockBackup::new();
    let subvol = PathBuf::from("/test-subvol");
    let snapshot = PathBuf::from("/test-subvol/.snapshot");

    // Act
    let result = run_backup_workflow(&btrfs, &backup, &subvol, &test_config(snapshot.clone()));

    // Assert
    assert!(result.is_ok(), "Workflow should succeed");

    // Verify snapshot was created
    assert!(
        btrfs.snapshot_created(&subvol, &snapshot),
        "Snapshot should be created"
    );

    // Verify snapshot was deleted after successful backup
    assert!(
        btrfs.subvolume_deleted(&snapshot),
        "Snapshot should be cleaned up after backup"
    );
}

#[test]
fn test_backup_failure_triggers_cleanup() {
    // Arrange
    let btrfs = MockBtrfs::new();
    let mut backup = MockBackup::new();
    backup.fail_backup = true;

    let subvol = PathBuf::from("/test-subvol");
    let snapshot = PathBuf::from("/test-subvol/.snapshot");

    // Act
    let result = run_backup_workflow(&btrfs, &backup, &subvol, &test_config(snapshot.clone()));

    // Assert
    assert!(result.is_err(), "Workflow should fail when backup fails");

    // Verify snapshot was created
    assert!(
        btrfs.snapshot_created(&subvol, &snapshot),
        "Snapshot should be created even when backup fails"
    );

    // Verify snapshot was cleaned up despite backup failure
    assert!(
        btrfs.subvolume_deleted(&snapshot),
        "Snapshot should be cleaned up even after backup failure"
    );
}

#[test]
fn test_snapshot_creation_failure() {
    // Arrange
    let mut btrfs = MockBtrfs::new();
    btrfs.fail_snapshot = true;
    let backup = MockBackup::new();

    let subvol = PathBuf::from("/test-subvol");
    let snapshot = PathBuf::from("/test-subvol/.snapshot");

    // Act
    let result = run_backup_workflow(&btrfs, &backup, &subvol, &test_config(snapshot.clone()));

    // Assert
    assert!(
        result.is_err(),
        "Workflow should fail when snapshot creation fails"
    );

    // Verify no cleanup attempted (snapshot was never created)
    assert!(
        !btrfs.snapshot_created(&subvol, &snapshot),
        "Snapshot should not be created when creation fails"
    );
}

#[test]
fn test_snapshot_deletion_after_success() {
    // Arrange
    let btrfs = MockBtrfs::new();
    let backup = MockBackup::new();

    let subvol = PathBuf::from("/test-subvol");
    let snapshot = PathBuf::from("/test-subvol/.snapshot");

    // Act
    let result = run_backup_workflow(&btrfs, &backup, &subvol, &test_config(snapshot.clone()));

    // Assert
    assert!(result.is_ok());
    assert_eq!(backup.backup_count(), 1, "Backup should run once");
    assert!(
        btrfs.subvolume_deleted(&snapshot),
        "Snapshot should be deleted after successful backup"
    );
}

#[test]
fn test_btrfs_uuid_retrieval() {
    // Arrange
    let btrfs = MockBtrfs::new();

    // Act
    let uuid = btrfs.get_subvolume_uuid(&PathBuf::from("/test"));

    // Assert
    assert!(uuid.is_ok());
    assert_eq!(
        uuid.ok(),
        Some("5ea01852-b4f9-4e4a-9c9d-f9c8b7a6e5d4".to_string())
    );
}

#[test]
fn test_multiple_backups_with_same_mock() {
    // Arrange
    let btrfs = MockBtrfs::new();
    let backup = MockBackup::new();

    // Act - Run multiple backups
    for index in 0..3 {
        let subvol = PathBuf::from(format!("/test-subvol-{index}"));
        let snapshot = PathBuf::from(format!("/test-subvol-{index}/.snapshot"));
        let result = run_backup_workflow(&btrfs, &backup, &subvol, &test_config(snapshot));
        assert!(result.is_ok());
    }

    // Assert
    assert_eq!(backup.backup_count(), 3, "Should run 3 backups");
}
