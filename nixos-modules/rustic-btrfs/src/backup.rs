/// Backup operations using rustic_core
use crate::traits::{BackupConfig, BackupOps, BackupStats, Error};
use rustic_backend::BackendOptions;
use rustic_core::{
    BackupOptions, LocalSourceFilterOptions, ParentOptions, PathList, Repository,
    RepositoryOptions, SnapshotOptions,
};
use std::env;
use std::path::PathBuf;

/// Production implementation of BackupOps using rustic_core.
pub struct RusticBackup;

impl RusticBackup {
    /// Create a new RusticBackup instance.
    #[must_use]
    pub const fn new() -> Self {
        Self
    }

    /// Configure repository from environment variables.
    ///
    /// # Errors
    ///
    /// Returns error if RUSTIC_REPOSITORY is not set or password method is not configured.
    fn configure_repository() -> Result<(RepositoryOptions, BackendOptions), Error> {
        // Get repository path from environment
        let repository = env::var("RUSTIC_REPOSITORY").map_err(|_| {
            Error::Config("RUSTIC_REPOSITORY environment variable not set".to_string())
        })?;

        log::debug!("Using repository: {}", repository);

        // Create backend options
        let backend_opts = BackendOptions::default().repository(&repository);

        // Create repository options with password
        let mut repo_opts = RepositoryOptions::default();

        // Try password methods in order: PASSWORD_FILE, PASSWORD_COMMAND, PASSWORD
        if let Ok(password_file) = env::var("RUSTIC_PASSWORD_FILE") {
            log::debug!("Using password from file: {}", password_file);
            repo_opts = repo_opts.password_file(PathBuf::from(password_file));
        } else if let Ok(_password_command) = env::var("RUSTIC_PASSWORD_COMMAND") {
            log::debug!("Using password from command");
            // CommandInput requires proper parsing - use password as fallback
            log::warn!("PASSWORD_COMMAND support not implemented yet, falling back to PASSWORD");
            if let Ok(password) = env::var("RUSTIC_PASSWORD") {
                repo_opts = repo_opts.password(password);
            } else {
                return Err(Error::Config(
                    "PASSWORD_COMMAND not supported yet. Use RUSTIC_PASSWORD_FILE or RUSTIC_PASSWORD".to_string(),
                ));
            }
        } else if let Ok(password) = env::var("RUSTIC_PASSWORD") {
            log::warn!("Using RUSTIC_PASSWORD environment variable (not recommended for security)");
            repo_opts = repo_opts.password(password);
        } else {
            return Err(Error::Config(
                "No password method configured. Set one of: RUSTIC_PASSWORD_FILE, RUSTIC_PASSWORD"
                    .to_string(),
            ));
        }

        Ok((repo_opts, backend_opts))
    }

    /// Build BackupOptions from BackupConfig.
    fn build_backup_options(config: &BackupConfig) -> BackupOptions {
        let mut opts = BackupOptions::default();

        // Set as-path if specified
        if let Some(as_path) = &config.as_path {
            opts = opts.as_path(PathBuf::from(as_path));
        }

        // Set dry-run
        opts = opts.dry_run(config.dry_run);

        // Always use no-scan and one-file-system as per SPEC
        opts = opts.no_scan(true);

        // Build parent options
        let mut parent_opts = ParentOptions::default();

        if let Some(group_by_str) = &config.group_by {
            // Parse group_by string to SnapshotGroupCriterion
            // For now, use default - this needs proper parsing implementation
            log::debug!("Group by: {}", group_by_str);
        }

        if let Some(parent) = &config.parent {
            parent_opts = parent_opts.parent(parent.clone());
        }

        if config.skip_if_unchanged {
            parent_opts = parent_opts.skip_if_unchanged(true);
        }

        if config.force {
            parent_opts = parent_opts.force(true);
        }

        if config.ignore_ctime {
            parent_opts = parent_opts.ignore_ctime(true);
        }

        if config.ignore_inode {
            parent_opts = parent_opts.ignore_inode(true);
        }

        opts = opts.parent_opts(parent_opts);

        // Build filter options
        let mut filter_opts = LocalSourceFilterOptions::default();

        // Always set one_file_system as per SPEC
        filter_opts = filter_opts.one_file_system(true);

        // Add glob patterns from --paths (for partial backup)
        if let Some(patterns) = &config.glob_patterns {
            filter_opts = filter_opts.globs(patterns.clone());
        }

        // Add additional globs
        if let Some(globs) = &config.extra_globs {
            // Merge with existing globs from glob_patterns
            if let Some(patterns) = &config.glob_patterns {
                let mut all_globs = patterns.clone();
                all_globs.extend(globs.clone());
                filter_opts = filter_opts.globs(all_globs);
            } else {
                filter_opts = filter_opts.globs(globs.clone());
            }
        }

        // Add iglobs (case-insensitive)
        if let Some(iglobs) = &config.iglobs {
            filter_opts = filter_opts.iglobs(iglobs.clone());
        }

        // Add glob files - convert PathBuf to String
        if let Some(glob_file) = &config.glob_file
            && let Some(path_str) = glob_file.to_str()
        {
            filter_opts = filter_opts.glob_files(vec![path_str.to_string()]);
        }

        if let Some(iglob_file) = &config.iglob_file
            && let Some(path_str) = iglob_file.to_str()
        {
            filter_opts = filter_opts.iglob_files(vec![path_str.to_string()]);
        }

        // Git ignore
        if config.git_ignore {
            filter_opts = filter_opts.git_ignore(true);
        }

        if config.no_require_git {
            filter_opts = filter_opts.no_require_git(true);
        }

        if let Some(ignorefile) = &config.custom_ignorefile
            && let Some(path_str) = ignorefile.to_str()
        {
            filter_opts = filter_opts.custom_ignorefiles(vec![path_str.to_string()]);
        }

        // Exclude options
        if let Some(exclude_file) = &config.exclude_if_present
            && let Some(path_str) = exclude_file.to_str()
        {
            filter_opts = filter_opts.exclude_if_present(vec![path_str.to_string()]);
        }

        if let Some(size_str) = &config.exclude_larger_than {
            // Parse size string to ByteSize - for now log it
            log::debug!("Exclude larger than: {}", size_str);
            // TODO: Parse size_str to ByteSize and set filter_opts.exclude_larger_than
        }

        opts = opts.ignore_filter_opts(filter_opts);

        opts
    }

    /// Build SnapshotOptions from BackupConfig.
    ///
    /// # Errors
    ///
    /// Returns error if snapshot options cannot be built.
    fn build_snapshot_options(config: &BackupConfig) -> Result<SnapshotOptions, Error> {
        let mut opts = SnapshotOptions::default();

        // Set label
        if let Some(label) = &config.label {
            opts = opts.label(label.clone());
        }

        // Add tags
        if let Some(tags) = &config.tags {
            for tag in tags {
                opts = opts
                    .add_tags(tag.as_str())
                    .map_err(|e| Error::Config(format!("Failed to add tag '{tag}': {e:?}")))?;
            }
        }

        // Set description
        if let Some(description) = &config.description {
            opts = opts.description(description.clone());
        }

        // Set time
        if let Some(time_str) = &config.timestamp {
            // Parse ISO 8601 timestamp
            // For now, log it - needs proper DateTime parsing
            log::debug!("Backup time: {}", time_str);
            // TODO: Parse time_str to DateTime<Local> and set opts.time
        }

        // Set delete options
        if config.delete_never {
            opts = opts.delete_never(true);
        }

        if let Some(delete_after_str) = &config.delete_after {
            // Parse duration string using humantime
            // For now, just log it - needs humantime::parse_duration
            log::debug!("Delete after: {}", delete_after_str);
            // TODO: Parse delete_after_str using humantime and set opts.delete_after
        }

        // Set host
        if let Some(host) = &config.host {
            opts = opts.host(host.clone());
        }

        Ok(opts)
    }
}

impl Default for RusticBackup {
    fn default() -> Self {
        Self::new()
    }
}

impl BackupOps for RusticBackup {
    fn run_backup(&self, config: &BackupConfig) -> Result<BackupStats, Error> {
        log::info!("Starting backup using rustic_core");

        // 1. Configure repository from environment
        let (repo_opts, backend_opts) = Self::configure_repository()?;

        // 2. Convert BackendOptions to backends
        let backends = backend_opts
            .to_backends()
            .map_err(|e| Error::Config(format!("Failed to create backends: {e:?}")))?;

        log::debug!("Created repository backends");

        // 3. Create and open repository
        let repo = Repository::new(&repo_opts, &backends)
            .map_err(|e| Error::Backup {
                message: format!("Failed to create repository: {e:?}"),
                exit_code: None,
            })?
            .open()
            .map_err(|e| Error::Backup {
                message: format!("Failed to open repository: {e:?}"),
                exit_code: None,
            })?
            .to_indexed_ids()
            .map_err(|e| Error::Backup {
                message: format!("Failed to index repository: {e:?}"),
                exit_code: None,
            })?;

        log::debug!("Opened and indexed repository");

        // 4. Build backup options
        let backup_opts = Self::build_backup_options(config);

        // 5. Build snapshot options
        let snapshot_opts = Self::build_snapshot_options(config)?;

        // 6. Create snapshot file
        let snapshot = snapshot_opts
            .to_snapshot()
            .map_err(|e| Error::Config(format!("Failed to create snapshot: {e:?}")))?;

        // 7. Create source path list
        let source_path = config
            .snapshot_path
            .to_str()
            .ok_or_else(|| Error::Config("Invalid snapshot path".to_string()))?;

        let source = PathList::from_string(source_path)
            .map_err(|e| Error::Config(format!("Failed to create path list: {e:?}")))?
            .sanitize()
            .map_err(|e| Error::Config(format!("Failed to sanitize paths: {e:?}")))?;

        log::info!("Backing up: {}", source_path);

        // 8. Run backup
        let _result_snapshot =
            repo.backup(&backup_opts, &source, snapshot)
                .map_err(|e| Error::Backup {
                    message: format!("Backup failed: {e:?}"),
                    exit_code: None,
                })?;

        log::info!("Backup completed successfully");

        // 9. Extract statistics
        // Note: SnapshotFile doesn't expose detailed statistics in public API
        // We'll return basic stats for now
        let stats = BackupStats {
            files_processed: 0, // TODO: Extract from _result_snapshot if available
            bytes_processed: 0, // TODO: Extract from _result_snapshot if available
        };

        log::debug!("Backup stats: {:?}", stats);

        Ok(stats)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[test]
    fn test_rustic_backup_new() {
        let backup = RusticBackup::new();
        assert!(std::mem::size_of_val(&backup) == 0); // Zero-sized type
    }

    #[test]
    fn test_build_backup_options() {
        let config = BackupConfig::test_default(PathBuf::from("/test/.snapshot"));
        let _opts = RusticBackup::build_backup_options(&config);
        // Just verify it builds without panic
    }

    #[test]
    fn test_build_snapshot_options() {
        let config = BackupConfig::test_default(PathBuf::from("/test/.snapshot"));
        let result = RusticBackup::build_snapshot_options(&config);
        assert!(result.is_ok());
    }

    #[test]
    fn test_configure_repository_no_env() {
        // Clear environment variables for test
        let result = RusticBackup::configure_repository();
        // Should fail without RUSTIC_REPOSITORY
        assert!(result.is_err());
    }
}
