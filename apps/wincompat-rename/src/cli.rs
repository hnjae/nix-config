#![expect(
    clippy::print_stdout,
    clippy::print_stderr,
    reason = "CLI interface requires direct stdout/stderr output for help, version, and error messages"
)]

use std::env;
use std::process;

/// The version of the application
const VERSION: &str = env!("CARGO_PKG_VERSION");
/// The help message displayed when --help is used
const HELP: &str = "\
wincompat-rename - Rename files to Windows-compatible names

USAGE:
    wincompat-rename [OPTIONS] <PATH>...
    wincompat-rename [OPTIONS] -- <PATH>...

ARGUMENTS:
    <PATH>...    Files or directories to process

OPTIONS:
    -r, --recursive              Recursively traverse directories
    -n, --dry-run                Show changes without actually renaming
    -H, --hidden                 Include hidden files (starting with .)
        --process-dangerous-files Process dangerous paths
    -h, --help                   Print help information
    -V, --version                Print version information
    --                           Stop parsing options (all following args are paths)
";

#[derive(Debug, Clone)]
#[expect(
    clippy::struct_excessive_bools,
    reason = "CLI args naturally have multiple boolean flags"
)]
#[non_exhaustive]
pub struct Args {
    pub dry_run: bool,
    pub hidden: bool,
    pub paths: Vec<String>,
    pub process_dangerous: bool,
    pub recursive: bool,
}

impl Default for Args {
    fn default() -> Self {
        Self::new()
    }
}

impl Args {
    #[must_use]
    pub const fn new() -> Self {
        Self {
            dry_run: false,
            hidden: false,
            paths: Vec::new(),
            process_dangerous: false,
            recursive: false,
        }
    }
}

/// Internal result type for argument parsing that can fail without exiting.
fn parse_args_internal(args: &[String]) -> Result<Args, String> {
    if args.is_empty() {
        return Err("help".to_owned());
    }

    let mut parsed = Args::new();
    let mut parsing_options = true;

    for arg in args {
        if parsing_options {
            match arg.as_str() {
                "-h" | "--help" => {
                    return Err("help".to_owned());
                }
                "-V" | "--version" => {
                    return Err("version".to_owned());
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
                "--" => {
                    parsing_options = false;
                }
                arg_str if arg_str.starts_with('-') => {
                    return Err(format!("unknown_option:{arg_str}"));
                }
                path => {
                    parsed.paths.push(path.to_owned());
                }
            }
        } else {
            parsed.paths.push(arg.to_owned());
        }
    }

    if parsed.paths.is_empty() {
        return Err("no_paths".to_owned());
    }

    Ok(parsed)
}

#[must_use]
pub fn parse_args() -> Args {
    let args: Vec<String> = env::args().collect();
    let args_slice = args.get(1..).unwrap_or_default();

    match parse_args_internal(args_slice) {
        Ok(parsed) => parsed,
        Err(error) => match error.as_str() {
            "help" => {
                println!("{HELP}");
                process::exit(0);
            }
            "version" => {
                println!("wincompat-rename {VERSION}");
                process::exit(0);
            }
            "no_paths" => {
                eprintln!("Error: No paths specified");
                eprintln!("Try 'wincompat-rename --help' for more information.");
                process::exit(1);
            }
            unknown_opt if unknown_opt.starts_with("unknown_option:") => {
                let opt = unknown_opt.strip_prefix("unknown_option:").unwrap_or("");
                eprintln!("Error: Unknown option '{opt}'");
                eprintln!("Try 'wincompat-rename --help' for more information.");
                process::exit(1);
            }
            _ => {
                eprintln!("Error: Invalid arguments");
                eprintln!("Try 'wincompat-rename --help' for more information.");
                process::exit(1);
            }
        },
    }
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

    #[test]
    fn test_parse_args_internal_simple_path() {
        let args = vec!["test.txt".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert_eq!(parsed.paths, vec!["test.txt"]);
        assert!(!parsed.recursive);
    }

    #[test]
    fn test_parse_args_internal_multiple_paths() {
        let args = vec!["file1.txt".to_string(), "file2.txt".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert_eq!(parsed.paths.len(), 2);
    }

    #[test]
    fn test_parse_args_internal_recursive_flag() {
        let args = vec!["-r".to_string(), "path".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert!(parsed.recursive);
        assert_eq!(parsed.paths, vec!["path"]);
    }

    #[test]
    fn test_parse_args_internal_recursive_long_flag() {
        let args = vec!["--recursive".to_string(), "path".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert!(parsed.recursive);
    }

    #[test]
    fn test_parse_args_internal_dry_run_flag() {
        let args = vec!["-n".to_string(), "path".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert!(parsed.dry_run);
    }

    #[test]
    fn test_parse_args_internal_dry_run_long_flag() {
        let args = vec!["--dry-run".to_string(), "path".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert!(parsed.dry_run);
    }

    #[test]
    fn test_parse_args_internal_hidden_flag() {
        let args = vec!["-H".to_string(), "path".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert!(parsed.hidden);
    }

    #[test]
    fn test_parse_args_internal_hidden_long_flag() {
        let args = vec!["--hidden".to_string(), "path".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert!(parsed.hidden);
    }

    #[test]
    fn test_parse_args_internal_process_dangerous_files() {
        let args = vec!["--process-dangerous-files".to_string(), "path".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert!(parsed.process_dangerous);
    }

    #[test]
    fn test_parse_args_internal_multiple_flags() {
        let args = vec![
            "-r".to_string(),
            "-n".to_string(),
            "-H".to_string(),
            "path".to_string(),
        ];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert!(parsed.recursive);
        assert!(parsed.dry_run);
        assert!(parsed.hidden);
        assert_eq!(parsed.paths, vec!["path"]);
    }

    #[test]
    fn test_parse_args_internal_help_flag() {
        let args = vec!["--help".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "help");
    }

    #[test]
    fn test_parse_args_internal_help_short_flag() {
        let args = vec!["-h".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "help");
    }

    #[test]
    fn test_parse_args_internal_version_flag() {
        let args = vec!["--version".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "version");
    }

    #[test]
    fn test_parse_args_internal_version_short_flag() {
        let args = vec!["-V".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "version");
    }

    #[test]
    fn test_parse_args_internal_unknown_option() {
        let args = vec!["--unknown".to_string(), "path".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_err());
        assert!(result.unwrap_err().starts_with("unknown_option:"));
    }

    #[test]
    fn test_parse_args_internal_no_paths() {
        let args = vec!["-r".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "no_paths");
    }

    #[test]
    fn test_parse_args_internal_empty_args() {
        let args: Vec<String> = vec![];
        let result = parse_args_internal(&args);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "help");
    }

    #[test]
    fn test_parse_args_internal_double_dash() {
        let args = vec!["--".to_string(), "-r".to_string(), "-n".to_string()];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        assert!(!parsed.recursive);
        assert!(!parsed.dry_run);
        assert_eq!(parsed.paths, vec!["-r".to_string(), "-n".to_string()]);
    }

    #[test]
    fn test_parse_args_internal_flags_interleaved_with_paths() {
        let args = vec![
            "-r".to_string(),
            "path1".to_string(),
            "-n".to_string(),
            "path2".to_string(),
        ];
        let result = parse_args_internal(&args);
        assert!(result.is_ok());
        let parsed = result.unwrap();
        // Both flags are processed even if interleaved with paths
        assert!(parsed.recursive);
        assert!(parsed.dry_run);
        assert_eq!(parsed.paths, vec!["path1".to_string(), "path2".to_string()]);
    }

    #[test]
    fn test_args_default() {
        let args = Args::default();
        assert_eq!(args.paths.len(), 0);
        assert!(!args.recursive);
        assert!(!args.dry_run);
        assert!(!args.hidden);
        assert!(!args.process_dangerous);
    }
}
