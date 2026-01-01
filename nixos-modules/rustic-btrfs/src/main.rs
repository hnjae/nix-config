/// Trait definitions for testability
mod traits;

/// Btrfs operations using libbtrfsutil
mod btrfs;

/// File-based locking to prevent concurrent backups
mod lock;

/// Backup operations using rustic_core
mod backup;

/// Command-line interface
mod cli;

/// Logging configuration
mod logging;

/// Progress reporting
mod progress;

/// Backup workflow with cleanup guarantees
mod workflow;

/// Mock implementations for testing
#[cfg(test)]
mod mocks;

use clap::{CommandFactory, Parser};
use clap_complete::{Shell as CompletionShell, generate};
use clap_mangen::Man;
use std::io;
use std::process;

/// Main entry point
fn main() {
    // Parse command-line arguments
    let cli = cli::Cli::parse();

    // Handle special commands (before logging initialization to avoid log output)
    if let Some(ref shell) = cli.special.generate_completion {
        generate_completion(shell);
        return;
    }

    if cli.special.generate_manpage {
        generate_manpage();
        return;
    }

    // Initialize logging based on --debug flag
    logging::init_logger(cli.global.debug);

    // Validate arguments
    if let Err(e) = cli.validate() {
        log::error!("Invalid arguments: {e}");
        process::exit(1);
    }

    // Run backup workflow
    if let Err(e) = run_backup(&cli) {
        log::error!("Backup failed: {:?}", e);
        process::exit(e.exit_code());
    }

    log::info!("Backup completed successfully");
}

/// Run the backup workflow
fn run_backup(cli: &cli::Cli) -> Result<(), traits::Error> {
    use backup::RusticBackup;
    use btrfs::LibBtrfs;
    use lock::LockGuard;
    use traits::BtrfsOps;

    log::info!("Starting rustic-btrfs backup");

    // Get subvolume path (already validated)
    let subvolume = cli
        .subvolume
        .as_ref()
        .ok_or_else(|| traits::Error::ConfigError("Subvolume is required".to_owned()))?;

    log::info!("Backup source: {}", subvolume.display());

    // Create Btrfs operations
    let btrfs = LibBtrfs::new();

    // Validate subvolume exists and is a Btrfs subvolume
    log::debug!("Validating subvolume path");
    if !subvolume.exists() {
        return Err(traits::Error::ConfigError(format!(
            "Subvolume does not exist: {}",
            subvolume.display()
        )));
    }

    if !btrfs.is_subvolume(subvolume)? {
        return Err(traits::Error::ConfigError(format!(
            "Path is not a Btrfs subvolume: {}",
            subvolume.display()
        )));
    }

    // Get subvolume UUID for locking
    log::debug!("Getting subvolume UUID");
    let uuid = btrfs.get_subvolume_uuid(subvolume)?;
    log::info!("Subvolume UUID: {uuid}");

    // Acquire exclusive lock
    log::debug!("Acquiring lock for UUID: {uuid}");
    let _lock = LockGuard::acquire(&uuid)?;
    log::info!("Lock acquired");

    // Check for snapshot conflicts
    let snapshot_path = subvolume.join(".snapshot");
    if snapshot_path.exists() {
        log::debug!("Checking existing .snapshot path");
        if !btrfs.is_subvolume(&snapshot_path)? {
            return Err(traits::Error::SnapshotConflict(format!(
                "Path {} exists but is not a subvolume. Manual cleanup required.",
                snapshot_path.display()
            )));
        }
        log::warn!(
            "Snapshot already exists (leftover from failed backup?): {}. Will be overwritten.",
            snapshot_path.display()
        );
        // Delete the existing snapshot before creating a new one
        btrfs.delete_subvolume(&snapshot_path)?;
    }

    // Build backup configuration
    let backup_config = build_backup_config(cli, &snapshot_path)?;

    // Create backup operations
    let backup_ops = RusticBackup::new();

    // Run the backup workflow
    log::info!("Running backup workflow");
    let stats = workflow::run_backup_workflow(&btrfs, &backup_ops, subvolume, &backup_config)?;

    log::info!(
        "Backup statistics: {} files processed, {} bytes",
        stats.files_processed,
        stats.bytes_processed
    );

    Ok(())
}

/// Build `BackupConfig` from CLI arguments
fn build_backup_config(
    cli: &cli::Cli,
    snapshot_path: &std::path::Path,
) -> Result<traits::BackupConfig, traits::Error> {
    // Build glob patterns if specified
    let glob_patterns = cli.backup_opts.glob.clone();

    // Build as_path (for partial backups, use parent directory name)
    let as_path = if cli.backup_opts.paths.is_some() {
        cli.subvolume
            .as_ref()
            .and_then(|p| p.file_name())
            .and_then(|n| n.to_str())
            .map(String::from)
    } else {
        None
    };

    // Build description
    let description = if let Some(ref desc) = cli.backup_opts.description {
        Some(desc.clone())
    } else if let Some(ref desc_file) = cli.backup_opts.description_from {
        // Read description from file
        let content = std::fs::read_to_string(desc_file).map_err(|e| {
            traits::Error::ConfigError(format!("Failed to read description file: {e}"))
        })?;
        Some(content.trim().to_owned())
    } else {
        cli.backup_opts
            .paths
            .as_ref()
            .map(|paths| cli::generate_partial_backup_description(paths))
    };

    Ok(traits::BackupConfig {
        snapshot_path: snapshot_path.to_path_buf(),
        glob_patterns,
        as_path,
        description,
        timestamp: cli.backup_opts.time.clone(),

        // Parent processing options
        group_by: cli.backup_opts.group_by.clone(),
        parent: cli.backup_opts.parent.clone(),
        skip_if_unchanged: cli.backup_opts.skip_if_unchanged,
        force: cli.backup_opts.force,
        ignore_ctime: cli.backup_opts.ignore_ctime,
        ignore_inode: cli.backup_opts.ignore_inode,

        // Exclude options
        extra_globs: cli.backup_opts.glob.clone(),
        iglobs: cli.backup_opts.iglob.clone(),
        glob_file: cli.backup_opts.glob_file.clone(),
        iglob_file: cli.backup_opts.iglob_file.clone(),
        git_ignore: cli.backup_opts.git_ignore,
        no_require_git: cli.backup_opts.no_require_git,
        custom_ignorefile: cli.backup_opts.custom_ignorefile.clone(),
        exclude_if_present: cli.backup_opts.exclude_if_present.clone(),
        exclude_larger_than: cli.backup_opts.exclude_larger_than.clone(),

        // Snapshot metadata
        label: cli.backup_opts.label.clone(),
        tags: cli.backup_opts.tag.clone(),
        delete_never: cli.backup_opts.delete_never,
        delete_after: cli.backup_opts.delete_after.clone(),
        host: cli.backup_opts.host.clone(),

        // Dry-run
        dry_run: cli.backup_opts.dry_run,
    })
}

/// Generate shell completion script
fn generate_completion(shell: &cli::Shell) {
    let mut cmd = cli::Cli::command();
    let shell_type = match shell {
        cli::Shell::Bash => CompletionShell::Bash,
        cli::Shell::Fish => CompletionShell::Fish,
        cli::Shell::Zsh => CompletionShell::Zsh,
        cli::Shell::Elvish => CompletionShell::Elvish,
        cli::Shell::Powershell => CompletionShell::PowerShell,
    };

    generate(shell_type, &mut cmd, "rustic-btrfs", &mut io::stdout());
}

/// Generate man page
fn generate_manpage() {
    let cmd = cli::Cli::command();
    let man = Man::new(cmd);
    man.render(&mut io::stdout()).ok();
}
