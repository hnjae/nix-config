use log::{Level, Log, Metadata, Record};
use wincompat_rename::{parse_args, walk_and_rename};

struct StderrLogger;

#[expect(clippy::print_stderr, reason = "Logger backend implementation")]
impl Log for StderrLogger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        metadata.level() <= Level::Info
    }

    fn log(&self, record: &Record) {
        if self.enabled(record.metadata()) {
            eprintln!("{}", record.args());
        }
    }

    fn flush(&self) {}
}

static LOGGER: StderrLogger = StderrLogger;

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
