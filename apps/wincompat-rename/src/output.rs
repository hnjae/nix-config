use log::{error, info};

/// Manages color support for terminal output.
///
/// This struct determines whether to use ANSI color codes based on
/// the terminal environment.
pub struct ColorSupport {
    /// Whether color output is enabled
    enabled: bool,
}

impl Default for ColorSupport {
    fn default() -> Self {
        Self::new()
    }
}

impl ColorSupport {
    /// Formats text with green color if colors are enabled.
    ///
    /// # Returns
    /// The text with ANSI green color codes if enabled, otherwise plain text.
    fn green(&self, text: &str) -> String {
        if self.enabled {
            format!("\x1b[32m{text}\x1b[0m")
        } else {
            text.to_owned()
        }
    }

    #[must_use]
    pub fn new() -> Self {
        let enabled = is_terminal();
        Self { enabled }
    }

    /// Formats text with yellow color if colors are enabled.
    ///
    /// # Returns
    /// The text with ANSI yellow color codes if enabled, otherwise plain text.
    fn yellow(&self, text: &str) -> String {
        if self.enabled {
            format!("\x1b[33m{text}\x1b[0m")
        } else {
            text.to_owned()
        }
    }
}

/// Summary of rename operations.
///
/// Tracks the number of files and directories renamed, as well as
/// items that were skipped for various reasons.
#[non_exhaustive]
pub struct Summary {
    /// Number of directories successfully renamed
    pub dirs_renamed: usize,
    /// Number of files successfully renamed
    pub files_renamed: usize,
    /// Number of items skipped because they are dangerous paths
    pub skipped_dangerous: usize,
    /// Number of items skipped because target already exists
    pub skipped_exists: usize,
    /// Number of items skipped because they are on different filesystems
    pub skipped_filesystem: usize,
}

impl Default for Summary {
    fn default() -> Self {
        Self::new()
    }
}

impl Summary {
    #[must_use]
    pub const fn new() -> Self {
        Self {
            dirs_renamed: 0,
            files_renamed: 0,
            skipped_dangerous: 0,
            skipped_exists: 0,
            skipped_filesystem: 0,
        }
    }
}

/// Determines if the output is a terminal that supports colors.
///
/// Checks the `NO_COLOR` and `TERM` environment variables to decide
/// whether to enable colored output.
fn is_terminal() -> bool {
    use std::env;

    if env::var("NO_COLOR").is_ok() {
        return false;
    }

    env::var("TERM").is_ok_and(|term| term != "dumb")
}

pub fn print_rename(old_name: &str, new_name: &str, current: usize, total: usize) {
    let colors = ColorSupport::new();
    info!(
        "({}/{}) {} → {}",
        current,
        total,
        old_name,
        colors.green(new_name)
    );
}

pub fn print_summary(summary: &Summary) {
    info!(
        "\nCompleted: {} files renamed, {} directories renamed",
        summary.files_renamed, summary.dirs_renamed
    );

    let total_skipped = summary
        .skipped_exists
        .saturating_add(summary.skipped_dangerous)
        .saturating_add(summary.skipped_filesystem);
    if total_skipped > 0 {
        let mut parts = Vec::new();

        if summary.skipped_exists > 0 {
            parts.push(format!("{} (target exists)", summary.skipped_exists));
        }
        if summary.skipped_dangerous > 0 {
            parts.push(format!("{} (dangerous path)", summary.skipped_dangerous));
        }
        if summary.skipped_filesystem > 0 {
            parts.push(format!(
                "{} (different filesystem)",
                summary.skipped_filesystem
            ));
        }

        info!("Skipped: {}", parts.join(", "));
    }
}

pub fn print_warning(message: &str) {
    let colors = ColorSupport::new();
    error!("{}", colors.yellow(message));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_summary_new() {
        let summary = Summary::new();
        assert_eq!(summary.files_renamed, 0);
        assert_eq!(summary.dirs_renamed, 0);
        assert_eq!(summary.skipped_exists, 0);
        assert_eq!(summary.skipped_dangerous, 0);
    }

    #[test]
    fn test_color_support() {
        let colors = ColorSupport::new();
        let yellow = colors.yellow("test");
        let green = colors.green("test");

        assert!(yellow.contains("test"));
        assert!(green.contains("test"));
    }
}
