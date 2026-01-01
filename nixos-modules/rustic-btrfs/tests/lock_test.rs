/// Integration tests for file locking
///
/// Tests concurrent backup prevention using real file locks
use rustic_btrfs::lock::acquire_lock;
use std::fs;
use std::path::PathBuf;
use tempfile::TempDir;

#[test]
fn test_lock_acquisition_success() {
    // Arrange
    let lock_dir = TempDir::new().expect("Failed to create temp dir");
    let uuid = "test-uuid-12345678-1234-1234-1234-123456789abc";

    // Act
    let result = acquire_lock(lock_dir.path(), uuid);

    // Assert
    assert!(result.is_ok(), "Lock acquisition should succeed");

    // Verify lock file was created
    let lock_file_path = lock_dir.path().join(format!("{uuid}.lock"));
    assert!(
        lock_file_path.exists(),
        "Lock file should be created at {}",
        lock_file_path.display()
    );
}

#[test]
fn test_concurrent_lock_acquisition_fails() {
    // Arrange
    let lock_dir = TempDir::new().expect("Failed to create temp dir");
    let uuid = "test-uuid-concurrent";

    // Act - First lock acquisition
    let _guard1 = acquire_lock(lock_dir.path(), uuid).expect("First lock should succeed");

    // Act - Second lock acquisition (should fail)
    let result2 = acquire_lock(lock_dir.path(), uuid);

    // Assert
    assert!(
        result2.is_err(),
        "Second lock acquisition should fail when first lock is held"
    );
}

#[test]
fn test_lock_released_on_drop() {
    // Arrange
    let lock_dir = TempDir::new().expect("Failed to create temp dir");
    let uuid = "test-uuid-release";

    // Act - Acquire and release lock
    {
        let _guard = acquire_lock(lock_dir.path(), uuid).expect("Lock should succeed");
        // Lock is dropped here
    }

    // Try to acquire again
    let result = acquire_lock(lock_dir.path(), uuid);

    // Assert
    assert!(
        result.is_ok(),
        "Lock acquisition should succeed after previous lock was released"
    );
}

#[test]
fn test_different_uuids_can_lock_concurrently() {
    // Arrange
    let lock_dir = TempDir::new().expect("Failed to create temp dir");
    let uuid1 = "test-uuid-1";
    let uuid2 = "test-uuid-2";

    // Act
    let _guard1 = acquire_lock(lock_dir.path(), uuid1).expect("First lock should succeed");
    let result2 = acquire_lock(lock_dir.path(), uuid2);

    // Assert
    assert!(
        result2.is_ok(),
        "Different UUIDs should be able to acquire locks concurrently"
    );
}

#[test]
fn test_lock_directory_created_if_missing() {
    // Arrange
    let temp_dir = TempDir::new().expect("Failed to create temp dir");
    let lock_dir = temp_dir.path().join("nested/lock/dir");
    let uuid = "test-uuid-nested";

    // Ensure directory doesn't exist
    assert!(
        !lock_dir.exists(),
        "Lock directory should not exist initially"
    );

    // Act
    let result = acquire_lock(&lock_dir, uuid);

    // Assert
    assert!(
        result.is_ok(),
        "Lock should succeed even when directory doesn't exist"
    );
    assert!(lock_dir.exists(), "Lock directory should be created");
}

#[test]
fn test_lock_file_format() {
    // Arrange
    let lock_dir = TempDir::new().expect("Failed to create temp dir");
    let uuid = "12345678-1234-1234-1234-123456789abc";

    // Act
    let _guard = acquire_lock(lock_dir.path(), uuid).expect("Lock should succeed");

    // Assert - Check lock file naming
    let lock_file = lock_dir.path().join(format!("{uuid}.lock"));
    assert!(
        lock_file.exists(),
        "Lock file should follow UUID.lock naming convention"
    );

    // Check it's a regular file
    let metadata = fs::metadata(&lock_file).expect("Should get metadata");
    assert!(metadata.is_file(), "Lock should be a regular file");
}
