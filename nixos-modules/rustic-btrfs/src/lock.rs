/// File-based locking to prevent concurrent backups
use crate::traits::Error;
use fs4::fs_std::FileExt as _;
use std::fs::File;
use std::path::{Path, PathBuf};

/// Default lock directory (created by systemd tmpfiles.d)
const LOCK_DIR: &str = "/run/lock/rustic-btrfs";

/// Guard that holds an exclusive file lock.
/// The lock is automatically released when this guard is dropped.
pub struct LockGuard {
    /// The lock file
    _file: File,
    /// Path to the lock file for cleanup
    path: PathBuf,
}

impl LockGuard {
    /// Acquire an exclusive lock for a subvolume UUID.
    ///
    /// # Arguments
    ///
    /// * `uuid` - The subvolume UUID (RFC 4122 format)
    ///
    /// # Errors
    ///
    /// Returns error if:
    /// - Lock directory doesn't exist
    /// - Cannot create lock file
    /// - Lock is already held by another process
    ///
    /// # Example
    ///
    /// ```ignore
    /// let lock = LockGuard::acquire("5ea01852-b4f9-4e4a-9c9d-f9c8b7a6e5d4")?;
    /// // Lock held until `lock` is dropped
    /// ```
    pub fn acquire(uuid: &str) -> Result<Self, Error> {
        let lock_path = Self::lock_path(uuid);
        log::debug!("Attempting to acquire lock: {}", lock_path.display());

        // Create lock file (or open if exists)
        let file = File::create(&lock_path).map_err(|error| {
            log::error!(
                "Failed to create lock file {}: {}",
                lock_path.display(),
                error
            );
            Error::Lock(format!(
                "Failed to create lock file {}: {}",
                lock_path.display(),
                error
            ))
        })?;

        // Try to acquire exclusive lock (non-blocking)
        file.try_lock_exclusive().map_err(|error| {
            log::error!("Another backup is already running for this subvolume");
            Error::Lock(format!(
                "Another backup is already running for this subvolume: {error}"
            ))
        })?;

        log::debug!("Lock acquired successfully");
        Ok(Self {
            _file: file,
            path: lock_path,
        })
    }

    /// Get the lock file path for a UUID.
    ///
    /// # Arguments
    ///
    /// * `uuid` - The subvolume UUID
    ///
    /// # Returns
    ///
    /// Path: `/run/lock/rustic-btrfs/<uuid>.lock`
    #[must_use]
    pub fn lock_path(uuid: &str) -> PathBuf {
        Path::new(LOCK_DIR).join(format!("{uuid}.lock"))
    }

    /// Get the path to this lock file.
    #[must_use]
    pub fn path(&self) -> &Path {
        &self.path
    }
}

impl Drop for LockGuard {
    fn drop(&mut self) {
        // Lock is automatically released when file is dropped.
        // We don't need to explicitly unlock or delete the file.
        // The file persists but the lock is released, which is fine.
    }
}

/// Acquire an exclusive lock for a UUID with a custom lock directory.
///
/// This function is exported for testing purposes.
///
/// # Errors
///
/// Returns `Error::Lock` if the lock cannot be acquired.
pub fn acquire_lock(lock_dir: &Path, uuid: &str) -> Result<LockGuard, Error> {
    // Ensure lock directory exists
    std::fs::create_dir_all(lock_dir)
        .map_err(|error| Error::Lock(format!("Failed to create lock directory: {error}")))?;

    let lock_path = lock_dir.join(format!("{uuid}.lock"));

    // Create lock file
    let file = File::create(&lock_path)
        .map_err(|error| Error::Lock(format!("Failed to create lock file: {error}")))?;

    // Try to acquire exclusive lock (non-blocking)
    file.try_lock_exclusive().map_err(|error| {
        Error::Lock(format!(
            "Another backup is already running for this subvolume: {error}"
        ))
    })?;

    Ok(LockGuard {
        _file: file,
        path: lock_path,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_lock_path() {
        let uuid = "5ea01852-b4f9-4e4a-9c9d-f9c8b7a6e5d4";
        let path = LockGuard::lock_path(uuid);
        assert_eq!(
            path,
            PathBuf::from("/run/lock/rustic-btrfs/5ea01852-b4f9-4e4a-9c9d-f9c8b7a6e5d4.lock")
        );
    }
}
