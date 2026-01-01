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

    // TODO: Implement backup workflow in later phases
    // This will involve:
    // 1. Validate repository configuration
    // 2. Get subvolume UUID for locking
    // 3. Acquire lock
    // 4. Check for snapshot conflicts
    // 5. Create snapshot
    // 6. Run backup with rustic_core
    // 7. Delete snapshot (cleanup)
    // 8. Release lock (automatic via Drop)

    log::info!("Starting rustic-btrfs backup");
    log::error!("Backup workflow not yet implemented");
    process::exit(1);
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
