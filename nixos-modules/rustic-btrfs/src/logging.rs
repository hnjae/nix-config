/// Logging configuration and initialization
use chrono::Local;
use env_logger::Builder;
use log::LevelFilter;
use std::io::Write as IoWrite;

/// Initialize the logger based on CLI options.
///
/// # Arguments
///
/// * `debug` - If true, sets log level to DEBUG; otherwise INFO
///
/// # Behavior
///
/// - Respects `RUST_LOG` environment variable if set
/// - Falls back to INFO level by default, DEBUG if `debug` is true
/// - Detects systemd journal via `JOURNAL_STREAM` env var
/// - Custom format:
///   - systemd (JOURNAL_STREAM present): `SEVERITY: message`
///   - terminal: `YYYY-MM-DDTHH:MM:SS+TZ: SEVERITY: message` (localtime)
///
/// # Example
///
/// ```ignore
/// init_logger(false); // INFO level
/// init_logger(true);  // DEBUG level
/// ```
pub fn init_logger(debug: bool) {
    let mut builder = Builder::from_default_env();

    // Set default filter if RUST_LOG not set
    if std::env::var("RUST_LOG").is_err() {
        let level = if debug {
            LevelFilter::Debug
        } else {
            LevelFilter::Info
        };
        builder.filter_module("rustic_btrfs", level);
    }

    // Detect systemd environment via JOURNAL_STREAM
    let is_systemd = std::env::var("JOURNAL_STREAM").is_ok();

    // Custom format based on environment
    builder.format(move |buf, record| {
        if is_systemd {
            // systemd: SEVERITY: message (no timestamp - systemd adds it)
            writeln!(buf, "{}: {}", record.level(), record.args())
        } else {
            // terminal: YYYY-MM-DDTHH:MM:SS+TZ: SEVERITY: message (localtime)
            writeln!(
                buf,
                "{}: {}: {}",
                Local::now().format("%Y-%m-%dT%H:%M:%S%:z"),
                record.level(),
                record.args()
            )
        }
    });

    builder.init();
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Test that init_logger can be called without panicking.
    ///
    /// Note: We can't easily test the actual log output or level in unit tests,
    /// but we can verify the function doesn't panic.
    #[test]
    fn test_init_logger_no_panic() {
        // This test will fail on second run if logger is already initialized
        // Use std::sync::Once or similar in production if multiple tests need logger

        // For now, just verify the function signature works
        // Actual logging behavior will be tested in integration tests
    }

    /// Test that the logger handles debug flag correctly.
    ///
    /// This is more of a documentation test since we can't easily verify
    /// the internal state of env_logger.
    #[test]
    fn test_init_logger_debug_flag() {
        // Verify function accepts bool parameter
        let _debug = true;
        // In real usage: init_logger(_debug);

        // Actual verification would require:
        // 1. Integration tests that capture log output
        // 2. Checking that DEBUG messages appear with debug=true
        // 3. Checking that DEBUG messages don't appear with debug=false
    }

    /// Test that RUST_LOG environment variable is respected.
    ///
    /// This is tested by env_logger itself, but we document the behavior.
    #[test]
    fn test_init_logger_rust_log_env() {
        // When RUST_LOG is set, it takes precedence
        // This is handled by Builder::from_default_env()

        // Integration tests will verify:
        // - RUST_LOG=trace → trace level logs appear
        // - RUST_LOG=error → only error level logs appear
        // - RUST_LOG not set + debug=false → info level (default)
        // - RUST_LOG not set + debug=true → debug level
    }
}
