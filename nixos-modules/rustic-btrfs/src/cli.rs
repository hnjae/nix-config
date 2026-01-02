/// Command-line interface definition
use clap::{Args, Parser, ValueEnum};
use std::path::PathBuf;

/// Safely backup Btrfs subvolumes using rustic
#[derive(Parser, Debug)]
#[command(name = "rustic-btrfs")]
#[command(version, about, long_about = None)]
#[command(arg_required_else_help = true)]
pub struct Cli {
    /// Path to Btrfs subvolume to backup
    #[arg(value_name = "SUBVOLUME")]
    pub subvolume: Option<PathBuf>,

    /// Global options
    #[command(flatten)]
    pub global: GlobalOptions,

    /// Rustic backup options
    #[command(flatten)]
    pub backup_opts: BackupOptions,

    /// Special commands
    #[command(flatten)]
    pub special: SpecialCommands,
}

/// Global options
#[derive(Args, Debug)]
pub struct GlobalOptions {
    /// Enable debug logging (sets `RUST_LOG=rustic_btrfs=debug`)
    #[arg(long)]
    pub debug: bool,

    /// Override `RUSTIC_REPOSITORY` environment variable
    #[arg(long, value_name = "REPO", env = "RUSTIC_REPOSITORY")]
    pub repository: Option<String>,

    /// Override `RUSTIC_PASSWORD_FILE` environment variable
    #[arg(long, value_name = "FILE", env = "RUSTIC_PASSWORD_FILE")]
    pub password_file: Option<PathBuf>,
}

/// Rustic backup options (passthrough to `rustic_core`)
#[derive(Args, Debug)]
pub struct BackupOptions {
    /// Backup only specific paths within subvolume (comma-separated, relative paths)
    #[arg(long, value_name = "PATH[,PATH,..]", value_delimiter = ',')]
    pub paths: Option<Vec<String>>,

    /// Pass --dry-run to rustic (no actual backup)
    #[arg(long)]
    pub dry_run: bool,

    // Parent processing options
    /// Group snapshots by criterion (default: host,paths)
    #[arg(long, value_name = "CRITERION")]
    pub group_by: Option<String>,

    /// Specific parent snapshot
    #[arg(long, value_name = "SNAPSHOT")]
    pub parent: Option<String>,

    /// Skip backup if unchanged vs parent
    #[arg(long)]
    pub skip_if_unchanged: bool,

    /// No parent, read all files
    #[arg(long)]
    pub force: bool,

    /// Ignore ctime changes
    #[arg(long)]
    pub ignore_ctime: bool,

    /// Ignore inode changes
    #[arg(long)]
    pub ignore_inode: bool,

    // Exclude options
    /// Glob pattern to exclude/include (can be specified multiple times)
    #[arg(long, value_name = "GLOB")]
    pub glob: Option<Vec<String>>,

    /// Case-insensitive glob pattern
    #[arg(long, value_name = "GLOB")]
    pub iglob: Option<Vec<String>>,

    /// Read glob patterns from file
    #[arg(long, value_name = "FILE")]
    pub glob_file: Option<PathBuf>,

    /// Read case-insensitive glob patterns from file
    #[arg(long, value_name = "FILE")]
    pub iglob_file: Option<PathBuf>,

    /// Use .gitignore rules
    #[arg(long)]
    pub git_ignore: bool,

    /// Don't require git repo for git-ignore
    #[arg(long)]
    pub no_require_git: bool,

    /// Treat file as .gitignore
    #[arg(long, value_name = "FILE")]
    pub custom_ignorefile: Option<PathBuf>,

    /// Exclude directories containing this file
    #[arg(long, value_name = "FILE")]
    pub exclude_if_present: Option<PathBuf>,

    /// Exclude files larger than size
    #[arg(long, value_name = "SIZE")]
    pub exclude_larger_than: Option<String>,

    // Snapshot metadata options
    /// Label for snapshot
    #[arg(long, value_name = "LABEL")]
    pub label: Option<String>,

    /// Tags (comma-separated, can be specified multiple times)
    #[arg(long, value_name = "TAG[,TAG,..]", value_delimiter = ',')]
    pub tag: Option<Vec<String>>,

    /// Snapshot description (overrides auto-generated JSON for partial backups)
    #[arg(long, value_name = "DESC")]
    pub description: Option<String>,

    /// Read description from file
    #[arg(long, value_name = "FILE")]
    pub description_from: Option<PathBuf>,

    /// Override backup time (ISO 8601 format)
    #[arg(long, value_name = "TIME")]
    pub time: Option<String>,

    /// Mark snapshot as uneraseable
    #[arg(long)]
    pub delete_never: bool,

    /// Auto-delete snapshot after duration
    #[arg(long, value_name = "DURATION")]
    pub delete_after: Option<String>,

    /// Override hostname
    #[arg(long, value_name = "NAME")]
    pub host: Option<String>,
}

/// Special commands (mutually exclusive with backup)
#[derive(Args, Debug)]
#[group(multiple = false)]
pub struct SpecialCommands {
    /// Generate shell completion script to stdout
    #[arg(long, value_name = "SHELL", value_enum)]
    pub generate_completion: Option<Shell>,

    /// Generate man page to stdout
    #[arg(long)]
    pub generate_manpage: bool,
}

/// Supported shells for completion generation
#[derive(ValueEnum, Clone, Debug)]
pub enum Shell {
    Bash,
    Fish,
    Zsh,
    Elvish,
    Powershell,
}

impl Cli {
    /// Parse command-line arguments
    #[must_use]
    pub fn parse_args() -> Self {
        Self::parse()
    }

    /// Validate the CLI arguments
    ///
    /// # Errors
    ///
    /// Returns error if:
    /// - Subvolume is required but not provided (when not using special commands)
    /// - Paths in --paths contain invalid characters
    pub fn validate(&self) -> Result<(), String> {
        // If special command, subvolume not required
        if self.special.generate_completion.is_some() || self.special.generate_manpage {
            return Ok(());
        }

        // Otherwise, subvolume is required
        if self.subvolume.is_none() {
            return Err("SUBVOLUME argument is required".to_owned());
        }

        // Validate --paths if specified
        if let Some(paths) = &self.backup_opts.paths {
            for path in paths {
                validate_partial_path(path)?;
            }
        }

        Ok(())
    }
}

/// Validate a path for --paths option
///
/// # Errors
///
/// Returns error if path:
/// - Starts with `/` (must be relative)
/// - Contains `..` (parent directory references not allowed)
///
/// # Example
///
/// ```ignore
/// validate_partial_path("user/Documents")?;  // OK
/// validate_partial_path("/etc/nginx")?;      // Error: absolute path
/// validate_partial_path("../etc")?;          // Error: parent reference
/// ```
pub fn validate_partial_path(path: &str) -> Result<(), String> {
    if path.starts_with('/') {
        return Err(format!("Path must be relative (no leading /): {path}"));
    }

    if path.contains("..") {
        return Err(format!(
            "Path must not contain parent directory references (..): {path}"
        ));
    }

    Ok(())
}

/// Generate auto-generated JSON description for partial backups
///
/// # Arguments
///
/// * `paths` - List of paths included in the partial backup
///
/// # Returns
///
/// JSON string: `{"included_paths": ["path1", "path2", ...]}`
///
/// # Example
///
/// ```ignore
/// let paths = vec!["user/Documents".to_string(), "user/Photos".to_string()];
/// let desc = generate_partial_backup_description(&paths);
/// assert_eq!(desc, r#"{"included_paths":["user/Documents","user/Photos"]}"#);
/// ```
#[must_use]
pub fn generate_partial_backup_description(paths: &[String]) -> String {
    serde_json::json!({
        "included_paths": paths
    })
    .to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_partial_path_valid() {
        assert!(validate_partial_path("user/Documents").is_ok());
        assert!(validate_partial_path("Wallpapers").is_ok());
        assert!(validate_partial_path("etc/nginx/sites-enabled").is_ok());
    }

    #[test]
    fn test_validate_partial_path_absolute() {
        let result = validate_partial_path("/etc/nginx");
        assert!(result.is_err());
        assert!(result.err().is_some_and(|e| e.contains("must be relative")));
    }

    #[test]
    fn test_validate_partial_path_parent_ref() {
        let result = validate_partial_path("../etc");
        assert!(result.is_err());
        assert!(result.err().is_some_and(|e| e.contains("parent directory")));
    }

    #[test]
    fn test_generate_partial_backup_description() {
        let paths = vec!["user/Documents".to_string(), "user/Photos".to_string()];
        let desc = generate_partial_backup_description(&paths);

        // Parse to verify it's valid JSON
        let parsed: serde_json::Value =
            serde_json::from_str(&desc).expect("Generated description should be valid JSON");
        assert_eq!(
            parsed["included_paths"].as_array().map(|a| a.len()),
            Some(2)
        );
    }

    #[test]
    fn test_generate_partial_backup_description_escaping() {
        let paths = vec![r#"path with "quotes""#.to_string()];
        let desc = generate_partial_backup_description(&paths);

        // Should be valid JSON (properly escaped)
        assert!(serde_json::from_str::<serde_json::Value>(&desc).is_ok());
    }
}
