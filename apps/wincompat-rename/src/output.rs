use std::io::{self, Write};

pub struct ColorSupport {
    enabled: bool,
}

impl ColorSupport {
    pub fn new() -> Self {
        let enabled = is_terminal();
        Self { enabled }
    }

    fn yellow(&self, text: &str) -> String {
        if self.enabled {
            format!("\x1b[33m{}\x1b[0m", text)
        } else {
            text.to_string()
        }
    }

    fn green(&self, text: &str) -> String {
        if self.enabled {
            format!("\x1b[32m{}\x1b[0m", text)
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

pub fn print_rename(old_name: &str, new_name: &str) {
    let colors = ColorSupport::new();
    println!("{} → {}", old_name, colors.green(new_name));
}

pub fn print_warning(message: &str) {
    let colors = ColorSupport::new();
    eprintln!("{}", colors.yellow(&format!("WARNING: {}", message)));
}

pub struct ProgressBar {
    total: usize,
    current: usize,
    width: usize,
}

impl ProgressBar {
    pub fn new(total: usize) -> Self {
        Self {
            total,
            current: 0,
            width: 40,
        }
    }

    pub fn update(&mut self, current: usize) {
        self.current = current;
        self.draw();
    }

    fn draw(&self) {
        if self.total == 0 {
            return;
        }

        let percentage = (self.current as f64 / self.total as f64 * 100.0) as usize;
        let filled = (self.current as f64 / self.total as f64 * self.width as f64) as usize;
        let empty = self.width.saturating_sub(filled);

        let bar = format!(
            "\r[{}{}] {}% ({}/{})",
            "#".repeat(filled),
            "-".repeat(empty),
            percentage,
            self.current,
            self.total
        );

        print!("{}", bar);
        let _ = io::stdout().flush();
    }

    pub fn finish(&self) {
        println!();
    }
}

pub struct Summary {
    pub files_renamed: usize,
    pub dirs_renamed: usize,
    pub skipped_exists: usize,
    pub skipped_dangerous: usize,
    pub skipped_filesystem: usize,
}

impl Summary {
    pub fn new() -> Self {
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
    println!("\nCompleted: {} files renamed, {} directories renamed",
             summary.files_renamed, summary.dirs_renamed);

    let total_skipped = summary.skipped_exists + summary.skipped_dangerous + summary.skipped_filesystem;
    if total_skipped > 0 {
        print!("Skipped: ");
        let mut parts = Vec::new();

        if summary.skipped_exists > 0 {
            parts.push(format!("{} (target exists)", summary.skipped_exists));
        }
        if summary.skipped_dangerous > 0 {
            parts.push(format!("{} (dangerous path)", summary.skipped_dangerous));
        }
        if summary.skipped_filesystem > 0 {
            parts.push(format!("{} (different filesystem)", summary.skipped_filesystem));
        }

        println!("{}", parts.join(", "));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_progress_bar_new() {
        let pb = ProgressBar::new(100);
        assert_eq!(pb.total, 100);
        assert_eq!(pb.current, 0);
    }

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
