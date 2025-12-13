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
    use std::env;

    #[test]
    fn test_summary_new() {
        let summary = Summary::new();
        assert_eq!(summary.files_renamed, 0);
        assert_eq!(summary.dirs_renamed, 0);
        assert_eq!(summary.skipped_exists, 0);
        assert_eq!(summary.skipped_dangerous, 0);
    }

    #[test]
    fn test_summary_default() {
        let summary = Summary::default();
        assert_eq!(summary.files_renamed, 0);
        assert_eq!(summary.dirs_renamed, 0);
        assert_eq!(summary.skipped_exists, 0);
        assert_eq!(summary.skipped_dangerous, 0);
        assert_eq!(summary.skipped_filesystem, 0);
    }

    #[test]
    fn test_color_support() {
        let colors = ColorSupport::new();
        let yellow = colors.yellow("test");
        let green = colors.green("test");

        assert!(yellow.contains("test"));
        assert!(green.contains("test"));
    }

    #[test]
    fn test_color_support_default() {
        let colors = ColorSupport::default();
        let yellow = colors.yellow("test");
        let green = colors.green("test");

        assert!(yellow.contains("test"));
        assert!(green.contains("test"));
    }

    #[test]
    fn test_color_support_green() {
        let colors = ColorSupport::new();
        let green = colors.green("hello");
        assert!(green.contains("hello"));
    }

    #[test]
    fn test_color_support_yellow() {
        let colors = ColorSupport::new();
        let yellow = colors.yellow("warning");
        assert!(yellow.contains("warning"));
    }

    #[test]
    fn test_is_terminal_no_color_env() {
        let old_val = env::var("NO_COLOR");
        unsafe {
            env::set_var("NO_COLOR", "1");
        }
        let result = is_terminal();
        if let Ok(val) = old_val {
            unsafe {
                env::set_var("NO_COLOR", val);
            }
        } else {
            unsafe {
                env::remove_var("NO_COLOR");
            }
        }
        assert!(!result);
    }

    #[test]
    fn test_is_terminal_term_dumb() {
        let old_val = env::var("TERM");
        unsafe {
            env::set_var("TERM", "dumb");
        }
        let result = is_terminal();
        if let Ok(val) = old_val {
            unsafe {
                env::set_var("TERM", val);
            }
        } else {
            unsafe {
                env::remove_var("TERM");
            }
        }
        assert!(!result);
    }

    #[test]
    fn test_is_terminal_term_set() {
        let old_term = env::var("TERM");
        let old_no_color = env::var("NO_COLOR");

        unsafe {
            env::remove_var("NO_COLOR");
            env::set_var("TERM", "xterm");
        }

        let result = is_terminal();

        if let Ok(val) = old_term {
            unsafe {
                env::set_var("TERM", val);
            }
        } else {
            unsafe {
                env::remove_var("TERM");
            }
        }
        if let Ok(val) = old_no_color {
            unsafe {
                env::set_var("NO_COLOR", val);
            }
        }

        assert!(result);
    }

    #[test]
    fn test_is_terminal_neither_set() {
        let old_term = env::var("TERM");
        let old_no_color = env::var("NO_COLOR");

        unsafe {
            env::remove_var("TERM");
            env::remove_var("NO_COLOR");
        }

        let result = is_terminal();

        if let Ok(val) = old_term {
            unsafe {
                env::set_var("TERM", val);
            }
        }
        if let Ok(val) = old_no_color {
            unsafe {
                env::set_var("NO_COLOR", val);
            }
        }

        assert!(!result);
    }

    #[test]
    fn test_print_rename() {
        // This test verifies that print_rename doesn't panic
        print_rename("old.txt", "new.txt", 1, 5);
    }

    #[test]
    fn test_print_summary_no_skips() {
        let summary = Summary {
            files_renamed: 5,
            dirs_renamed: 2,
            skipped_dangerous: 0,
            skipped_exists: 0,
            skipped_filesystem: 0,
        };
        print_summary(&summary);
    }

    #[test]
    fn test_print_summary_with_skips() {
        let summary = Summary {
            files_renamed: 5,
            dirs_renamed: 2,
            skipped_dangerous: 1,
            skipped_exists: 2,
            skipped_filesystem: 1,
        };
        print_summary(&summary);
    }

    #[test]
    fn test_print_summary_only_dangerous() {
        let summary = Summary {
            files_renamed: 0,
            dirs_renamed: 0,
            skipped_dangerous: 3,
            skipped_exists: 0,
            skipped_filesystem: 0,
        };
        print_summary(&summary);
    }

    #[test]
    fn test_print_summary_only_exists() {
        let summary = Summary {
            files_renamed: 0,
            dirs_renamed: 0,
            skipped_dangerous: 0,
            skipped_exists: 2,
            skipped_filesystem: 0,
        };
        print_summary(&summary);
    }

    #[test]
    fn test_print_summary_only_filesystem() {
        let summary = Summary {
            files_renamed: 0,
            dirs_renamed: 0,
            skipped_dangerous: 0,
            skipped_exists: 0,
            skipped_filesystem: 1,
        };
        print_summary(&summary);
    }

    #[test]
    fn test_print_warning() {
        // This test verifies that print_warning doesn't panic
        print_warning("This is a warning");
    }
}
