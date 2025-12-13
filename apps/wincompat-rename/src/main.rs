//! CLI entry point for wincompat-rename.
//!
//! This binary provides a command-line interface for renaming files
//! to be compatible with Windows file systems.

use log::{Level, Log, Metadata, Record};
use wincompat_rename::{parse_args, walk_and_rename};

/// Global logger instance.
///
/// This static logger is registered with the log crate to handle
/// all logging throughout the application.
static LOGGER: StderrLogger = StderrLogger;

/// Simple logger that outputs to stderr.
///
/// This logger is used to display rename operations and warnings
/// to the user through stderr.
struct StderrLogger;

#[expect(clippy::print_stderr, reason = "Logger backend implementation")]
impl Log for StderrLogger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        metadata.level() <= Level::Info
    }

    fn flush(&self) {}

    fn log(&self, record: &Record) {
        if self.enabled(record.metadata()) {
            eprintln!("{}", record.args());
        }
    }
}

#[expect(
    clippy::expect_used,
    reason = "Logger initialization failure is unrecoverable"
)]
fn main() {
    log::set_logger(&LOGGER)
        .expect("Failed to set logger - this should only fail if logger is already initialized");
    log::set_max_level(log::LevelFilter::Info);

    let args = parse_args();
    walk_and_rename(args);
}
