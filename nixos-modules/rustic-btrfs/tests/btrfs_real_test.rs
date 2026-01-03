/// Real Btrfs integration tests using actual kernel interfaces
///
/// These tests verify that FFI bindings and actual Btrfs operations work correctly.
/// They require:
/// - BTRFS_TEST_PATH environment variable pointing to a Btrfs filesystem
/// - Tests will be skipped if the environment variable is not set
///
/// Run via: `sudo -E BTRFS_TEST_PATH=/path/to/btrfs just test-btrfs-real`
use regex::Regex;
use rustic_btrfs::btrfs::LibBtrfs;
use rustic_btrfs::traits::BtrfsOps;
use std::env;
use std::path::PathBuf;

/// Get the Btrfs test directory from environment variable
fn get_btrfs_test_dir() -> Option<PathBuf> {
    match env::var("BTRFS_TEST_PATH") {
        Ok(path) => Some(PathBuf::from(path)),
        Err(_) => {
            eprintln!("BTRFS_TEST_PATH not set, skipping real Btrfs integration tests");
            None
        }
    }
}

/// RAII guard for test subvolume cleanup
struct TestSubvolume {
    path: PathBuf,
}

impl Drop for TestSubvolume {
    fn drop(&mut self) {
        // Best-effort cleanup - don't panic in Drop
        let btrfs = LibBtrfs::new();
        let _ = btrfs.delete_subvolume(&self.path);
    }
}

#[test]
fn test_real_snapshot_creation_and_deletion() {
    let base_dir = match get_btrfs_test_dir() {
        Some(dir) => dir,
        None => return,
    };

    let btrfs = LibBtrfs::new();

    // Create unique test names to avoid conflicts
    let test_name = format!("rustic-btrfs-test-{}", std::process::id());
    let subvol = base_dir.join(&test_name);
    let snapshot = base_dir.join(format!("{test_name}.snapshot"));

    // Cleanup guards - ensure cleanup even on test failure
    let _cleanup = (
        TestSubvolume {
            path: subvol.clone(),
        },
        TestSubvolume {
            path: snapshot.clone(),
        },
    );

    // Create test subvolume (as a regular directory first)
    std::fs::create_dir(&subvol).expect("Failed to create test directory");

    // Test: Create read-only snapshot
    btrfs
        .create_snapshot(&subvol, &snapshot, true)
        .expect("Should create snapshot");

    // Verify snapshot exists
    assert!(snapshot.exists(), "Snapshot should exist after creation");

    // Test: Delete snapshot
    btrfs
        .delete_subvolume(&snapshot)
        .expect("Should delete snapshot");

    // Verify snapshot is deleted
    assert!(
        !snapshot.exists(),
        "Snapshot should not exist after deletion"
    );
}

#[test]
fn test_real_uuid_retrieval_and_format() {
    let base_dir = match get_btrfs_test_dir() {
        Some(dir) => dir,
        None => return,
    };

    let btrfs = LibBtrfs::new();

    // Get UUID of the test directory (should be a Btrfs subvolume)
    let uuid = btrfs
        .get_subvolume_uuid(&base_dir)
        .expect("Should get UUID from Btrfs subvolume");

    // Verify UUID format matches RFC 4122 (lowercase, hyphenated)
    let uuid_pattern =
        Regex::new(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
            .expect("UUID regex should compile");

    assert!(
        uuid_pattern.is_match(&uuid),
        "UUID should match RFC 4122 format (lowercase, hyphenated): got {uuid}"
    );
}

#[test]
fn test_real_is_subvolume() {
    let base_dir = match get_btrfs_test_dir() {
        Some(dir) => dir,
        None => return,
    };

    let btrfs = LibBtrfs::new();

    // Test: base_dir should be a Btrfs subvolume
    let is_subvol = btrfs
        .is_subvolume(&base_dir)
        .expect("Should check if path is subvolume");

    assert!(
        is_subvol,
        "BTRFS_TEST_PATH should point to a Btrfs subvolume"
    );

    // Create a regular directory and test it
    let test_name = format!("rustic-btrfs-regular-dir-{}", std::process::id());
    let regular_dir = base_dir.join(&test_name);

    std::fs::create_dir(&regular_dir).expect("Failed to create regular directory");

    let _cleanup = || {
        let _ = std::fs::remove_dir(&regular_dir);
    };

    // Test: regular directory should NOT be a subvolume
    let is_regular_subvol = btrfs
        .is_subvolume(&regular_dir)
        .expect("Should check if regular directory is subvolume");

    _cleanup();

    assert!(
        !is_regular_subvol,
        "Regular directory should not be detected as subvolume"
    );
}

#[test]
fn test_real_readonly_snapshot() {
    let base_dir = match get_btrfs_test_dir() {
        Some(dir) => dir,
        None => return,
    };

    let btrfs = LibBtrfs::new();

    // Create test subvolume
    let test_name = format!("rustic-btrfs-readonly-test-{}", std::process::id());
    let subvol = base_dir.join(&test_name);
    let snapshot = base_dir.join(format!("{test_name}.snapshot"));

    let _cleanup = (
        TestSubvolume {
            path: subvol.clone(),
        },
        TestSubvolume {
            path: snapshot.clone(),
        },
    );

    std::fs::create_dir(&subvol).expect("Failed to create test directory");

    // Create a file in the source subvolume
    let test_file = subvol.join("testfile.txt");
    std::fs::write(&test_file, b"test content").expect("Failed to write test file");

    // Create read-only snapshot
    btrfs
        .create_snapshot(&subvol, &snapshot, true)
        .expect("Should create read-only snapshot");

    // Verify snapshot is read-only by attempting to write
    let snapshot_file = snapshot.join("new-file.txt");
    let write_result = std::fs::write(&snapshot_file, b"should fail");

    assert!(
        write_result.is_err(),
        "Writing to read-only snapshot should fail"
    );

    // Verify the original file exists in the snapshot
    let snapshot_test_file = snapshot.join("testfile.txt");
    assert!(
        snapshot_test_file.exists(),
        "Original file should exist in snapshot"
    );

    let content =
        std::fs::read_to_string(&snapshot_test_file).expect("Should read file from snapshot");
    assert_eq!(content, "test content", "File content should match");
}
