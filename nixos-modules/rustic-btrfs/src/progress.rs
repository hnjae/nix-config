/// Progress reporting with TTY detection
use indicatif::{ProgressBar, ProgressStyle};
use std::io::IsTerminal as _;

/// Progress reporter that adapts to TTY vs non-TTY environments.
#[allow(dead_code)]
pub struct ProgressReporter {
    /// Progress bar (only created if stdout is a TTY)
    progress_bar: Option<ProgressBar>,
}

#[allow(dead_code)]
impl ProgressReporter {
    /// Create a new progress reporter.
    ///
    /// # Behavior
    ///
    /// - If stdout is a TTY: Creates an `indicatif` progress bar
    /// - If stdout is NOT a TTY (e.g., systemd): Uses logging only
    ///
    /// # Example
    ///
    /// ```ignore
    /// let reporter = ProgressReporter::new();
    /// reporter.start_backup("/home");
    /// reporter.finish("1.8GB in 45s");
    /// ```
    #[must_use]
    pub fn new() -> Self {
        let progress_bar = std::io::stdout().is_terminal().then(|| {
            let pb = ProgressBar::new(0);
            pb.set_style(
                ProgressStyle::default_bar()
                    .template("[{elapsed_precise}] {bar:40.cyan/blue} {pos}/{len} {msg}")
                    .ok()
                    .unwrap_or_else(ProgressStyle::default_bar),
            );
            pb
        });

        Self { progress_bar }
    }

    /// Report that backup has started for a subvolume.
    ///
    /// # Arguments
    ///
    /// * `subvolume` - Path to the subvolume being backed up
    pub fn start_backup(&self, subvolume: &str) {
        if let Some(pb) = &self.progress_bar {
            pb.set_message(format!("Backing up {subvolume}"));
        } else {
            log::info!("Starting backup of subvolume {subvolume}");
        }
    }

    /// Report that a snapshot has been created.
    ///
    /// # Arguments
    ///
    /// * `snapshot_path` - Path to the created snapshot
    pub fn snapshot_created(&self, snapshot_path: &str) {
        if let Some(pb) = &self.progress_bar {
            pb.set_message(format!("Snapshot created at {snapshot_path}"));
        } else {
            log::info!("Created snapshot at {snapshot_path}");
        }
    }

    /// Update progress with current state.
    ///
    /// # Arguments
    ///
    /// * `files_processed` - Number of files processed so far
    /// * `total_files` - Total number of files (if known)
    /// * `message` - Optional status message
    pub fn update(&self, files_processed: u64, total_files: Option<u64>, message: Option<&str>) {
        if let Some(pb) = &self.progress_bar {
            if let Some(total) = total_files {
                pb.set_length(total);
            }
            pb.set_position(files_processed);
            if let Some(msg) = message {
                pb.set_message(msg.to_owned());
            }
        }
        // Non-TTY: no need to log every update, only milestones
    }

    /// Report that backup has finished successfully.
    ///
    /// # Arguments
    ///
    /// * `stats` - Summary statistics (e.g., "1.8GB in 45s")
    pub fn finish(&self, stats: &str) {
        if let Some(pb) = &self.progress_bar {
            pb.finish_with_message(format!("Backup completed: {stats}"));
        } else {
            log::info!("Backup completed: {stats}");
        }
    }

    /// Report that backup failed.
    ///
    /// # Arguments
    ///
    /// * `error` - Error message
    pub fn fail(&self, error: &str) {
        if let Some(pb) = &self.progress_bar {
            pb.abandon_with_message(format!("Backup failed: {error}"));
        } else {
            log::error!("Backup failed: {error}");
        }
    }
}

impl Default for ProgressReporter {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Test that ProgressReporter can be created without panicking.
    ///
    /// Note: We can't easily test TTY detection in unit tests since stdin/stdout
    /// are typically not TTYs in test environments. This test mainly ensures
    /// the code compiles and doesn't panic.
    #[test]
    fn test_progress_reporter_new() {
        let reporter = ProgressReporter::new();
        // Should create without panic
        // In test environment, stdout is typically not a TTY, so progress_bar will be None
        reporter.start_backup("/test");
        reporter.snapshot_created("/test/.snapshot");
        reporter.update(50, Some(100), Some("Processing files"));
        reporter.finish("1.0GB in 10s");
    }

    /// Test that ProgressReporter can handle failure reporting.
    #[test]
    fn test_progress_reporter_fail() {
        let reporter = ProgressReporter::new();
        reporter.start_backup("/test");
        reporter.fail("Repository not found");
        // Should not panic
    }

    /// Test that ProgressReporter can handle updates without total.
    #[test]
    fn test_progress_reporter_update_no_total() {
        let reporter = ProgressReporter::new();
        reporter.update(50, None, Some("Processing files"));
        // Should not panic
    }
}
