use log::{error, info};

pub struct ColorSupport {
    enabled: bool,
}

impl Default for ColorSupport {
    fn default() -> Self {
        Self::new()
    }
}

impl ColorSupport {
    #[must_use]
    pub fn new() -> Self {
        let enabled = is_terminal();
        Self { enabled }
    }

    fn yellow(&self, text: &str) -> String {
        if self.enabled {
            format!("\x1b[33m{text}\x1b[0m")
        } else {
            text.to_string()
        }
    }

    fn green(&self, text: &str) -> String {
        if self.enabled {
            format!("\x1b[32m{text}\x1b[0m")
        } else {
            text.to_string()
        }
    }
}

fn is_terminal() -> bool {
    use std::env;

    if env::var("NO_COLOR").is_ok() {
        return false;
    }

    env::var("TERM").is_ok() && env::var("TERM").unwrap() != "dumb"
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

pub fn print_warning(message: &str) {
    let colors = ColorSupport::new();
    error!("{}", colors.yellow(message));
}

pub struct Summary {
    pub files_renamed: usize,
    pub dirs_renamed: usize,
    pub skipped_exists: usize,
    pub skipped_dangerous: usize,
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
            files_renamed: 0,
            dirs_renamed: 0,
            skipped_exists: 0,
            skipped_dangerous: 0,
            skipped_filesystem: 0,
        }
    }
}

pub fn print_summary(summary: &Summary) {
    info!(
        "\nCompleted: {} files renamed, {} directories renamed",
        summary.files_renamed, summary.dirs_renamed
    );

    let total_skipped =
        summary.skipped_exists + summary.skipped_dangerous + summary.skipped_filesystem;
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
