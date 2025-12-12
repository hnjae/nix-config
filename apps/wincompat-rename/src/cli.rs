use std::env;
use std::process;

const VERSION: &str = env!("CARGO_PKG_VERSION");
const HELP: &str = "\
wincompat-rename - Rename files to Windows-compatible names

USAGE:
    wincompat-rename [OPTIONS] <PATH>...

ARGUMENTS:
    <PATH>...    Files or directories to process

OPTIONS:
    -r, --recursive              Recursively traverse directories
    -n, --dry-run                Show changes without actually renaming
    -H, --hidden                 Include hidden files (starting with .)
        --process-dangerous-files Process dangerous paths
    -h, --help                   Print help information
    -V, --version                Print version information
";

#[derive(Debug, Clone)]
pub struct Args {
    pub paths: Vec<String>,
    pub recursive: bool,
    pub dry_run: bool,
    pub hidden: bool,
    pub process_dangerous: bool,
}

impl Args {
    pub fn new() -> Self {
        Self {
            paths: Vec::new(),
            recursive: false,
            dry_run: false,
            hidden: false,
            process_dangerous: false,
        }
    }
}

pub fn parse_args() -> Args {
    let args: Vec<String> = env::args().collect();

    if args.len() == 1 {
        println!("{}", HELP);
        process::exit(0);
    }

    let mut parsed = Args::new();
    let mut i = 1;

    while i < args.len() {
        match args[i].as_str() {
            "-h" | "--help" => {
                println!("{}", HELP);
                process::exit(0);
            }
            "-V" | "--version" => {
                println!("wincompat-rename {}", VERSION);
                process::exit(0);
            }
            "-r" | "--recursive" => {
                parsed.recursive = true;
            }
            "-n" | "--dry-run" => {
                parsed.dry_run = true;
            }
            "-H" | "--hidden" => {
                parsed.hidden = true;
            }
            "--process-dangerous-files" => {
                parsed.process_dangerous = true;
            }
            arg if arg.starts_with('-') => {
                eprintln!("Error: Unknown option '{}'", arg);
                eprintln!("Try 'wincompat-rename --help' for more information.");
                process::exit(1);
            }
            path => {
                parsed.paths.push(path.to_string());
            }
        }
        i += 1;
    }

    if parsed.paths.is_empty() {
        eprintln!("Error: No paths specified");
        eprintln!("Try 'wincompat-rename --help' for more information.");
        process::exit(1);
    }

    parsed
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_args_new() {
        let args = Args::new();
        assert_eq!(args.paths.len(), 0);
        assert!(!args.recursive);
        assert!(!args.dry_run);
        assert!(!args.hidden);
        assert!(!args.process_dangerous);
    }
}
