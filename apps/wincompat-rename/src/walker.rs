use crate::cli::Args;
use crate::converter::convert_filename;
use crate::fs_utils::{get_device_id, is_different_filesystem, is_hidden, is_symlink};
use crate::output::{Summary, print_rename, print_summary, print_warning};
use crate::safety::{check_collision, is_dangerous_path};
use std::cmp::Reverse;
use std::fs;
use std::path::{Path, PathBuf};

/// Context for walking and renaming files.
///
/// This struct holds the state needed during the file walking process,
/// including command-line arguments, device ID for filesystem checks,
/// and a summary of operations.
struct WalkContext {
    /// Command-line arguments
    args: Args,
    /// Base device ID for filesystem boundary checking
    base_dev: Option<u64>,
    /// Summary of rename operations
    summary: Summary,
}

pub fn walk_and_rename(args: Args) {
    let paths = args.paths.clone();
    let recursive = args.recursive;

    let mut ctx = WalkContext {
        args,
        base_dev: None,
        summary: Summary::new(),
    };

    for path_str in &paths {
        let path = PathBuf::from(path_str);

        if !path.exists() {
            print_warning(&format!("Path does not exist: {}", path.display()));
            continue;
        }

        if ctx.base_dev.is_none() {
            ctx.base_dev = get_device_id(&path);
        }

        if recursive && path.is_dir() {
            process_directory_recursive(&mut ctx, &path);
        } else {
            process_single_path(&mut ctx, &path, 1, 1);
        }
    }

    print_summary(&ctx.summary);
}

/// Processes a directory recursively, collecting and renaming all paths.
///
/// This function collects all paths in the directory tree, sorts them by depth
/// (deepest first to avoid renaming parent directories before children),
/// and processes each path for renaming.
fn process_directory_recursive(ctx: &mut WalkContext, dir: &Path) {
    let mut all_paths = Vec::new();
    collect_paths(ctx, dir, &mut all_paths);

    all_paths.sort_by_key(|path| Reverse(path.components().count()));

    if ctx.args.recursive {
        let total = all_paths.len();
        for (idx, path) in all_paths.iter().enumerate() {
            let current = idx.saturating_add(1);
            process_single_path(ctx, path, current, total);
        }
    }
}

/// Recursively collects all paths in a directory tree.
///
/// This function traverses a directory tree, respecting command-line flags
/// for hidden files, dangerous paths, and filesystem boundaries. It collects
/// all valid paths into the provided vector.
fn collect_paths(ctx: &mut WalkContext, dir: &Path, collected: &mut Vec<PathBuf>) {
    if is_symlink(dir) {
        return;
    }

    if !ctx.args.process_dangerous && is_dangerous_path(dir) {
        return;
    }

    if !ctx.args.hidden && is_hidden(dir) {
        return;
    }

    if let Some(base_dev) = ctx.base_dev
        && is_different_filesystem(dir, base_dev) {
            return;
        }

    let Ok(entries) = fs::read_dir(dir) else {
        return;
    };

    for entry in entries.flatten() {
        let path = entry.path();

        if is_symlink(&path) {
            continue;
        }

        if !ctx.args.hidden && is_hidden(&path) {
            continue;
        }

        if !ctx.args.process_dangerous && is_dangerous_path(&path) {
            ctx.summary.skipped_dangerous = ctx.summary.skipped_dangerous.saturating_add(1);
            continue;
        }

        if let Some(base_dev) = ctx.base_dev
            && is_different_filesystem(&path, base_dev) {
                print_warning(&format!(
                    "SKIPPED \"{}\" (different filesystem)",
                    path.display()
                ));
                ctx.summary.skipped_filesystem = ctx.summary.skipped_filesystem.saturating_add(1);
                continue;
            }

        collected.push(path.clone());

        if path.is_dir() {
            collect_paths(ctx, &path, collected);
        }
    }
}

/// Processes a single path for renaming.
///
/// This function checks if a path needs to be renamed to be Windows-compatible,
/// performs various safety checks, and either performs or simulates the rename
/// operation based on command-line flags.
fn process_single_path(ctx: &mut WalkContext, path: &Path, current: usize, total: usize) {
    if is_symlink(path) {
        return;
    }

    if !ctx.args.process_dangerous && is_dangerous_path(path) {
        print_warning(&format!("SKIPPED \"{}\" (dangerous path)", path.display()));
        ctx.summary.skipped_dangerous = ctx.summary.skipped_dangerous.saturating_add(1);
        return;
    }

    let Some(filename) = path.file_name() else {
        return;
    };

    let Some(filename_str) = filename.to_str() else {
        return;
    };

    let Some(new_filename) = convert_filename(filename_str) else {
        return;
    };

    let Some(parent) = path.parent() else {
        return;
    };

    let new_path = parent.join(&new_filename);

    if check_collision(&new_path) {
        print_warning(&format!(
            "SKIPPED \"{filename_str}\" → \"{new_filename}\" (target already exists)"
        ));
        ctx.summary.skipped_exists = ctx.summary.skipped_exists.saturating_add(1);
        return;
    }

    if ctx.args.dry_run {
        print_rename(filename_str, &new_filename, current, total);
    } else {
        match fs::rename(path, &new_path) {
            Ok(()) => {
                print_rename(filename_str, &new_filename, current, total);
                if path.is_dir() {
                    ctx.summary.dirs_renamed = ctx.summary.dirs_renamed.saturating_add(1);
                } else {
                    ctx.summary.files_renamed = ctx.summary.files_renamed.saturating_add(1);
                }
            }
            Err(err) => {
                print_warning(&format!(
                    "Failed to rename \"{filename_str}\" → \"{new_filename}\": {err}"
                ));
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn test_collect_paths_basic() {
        let temp_dir = std::env::temp_dir().join("test_walker_collect");
        let _ = fs::create_dir_all(&temp_dir);

        fs::write(temp_dir.join("file1.txt"), "test").expect("Failed to write file");
        fs::write(temp_dir.join("file2.txt"), "test").expect("Failed to write file");

        let mut ctx = WalkContext {
            args: Args::new(),
            base_dev: get_device_id(&temp_dir),
            summary: Summary::new(),
        };

        let mut collected = Vec::new();
        collect_paths(&mut ctx, &temp_dir, &mut collected);

        assert!(collected.len() >= 2);

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_process_single_path_no_change() {
        let temp_dir = std::env::temp_dir().join("test_walker_single");
        let _ = fs::create_dir_all(&temp_dir);

        let file_path = temp_dir.join("normal_file.txt");
        fs::write(&file_path, "test").expect("Failed to write test file");

        let mut ctx = WalkContext {
            args: Args::new(),
            base_dev: get_device_id(&temp_dir),
            summary: Summary::new(),
        };

        process_single_path(&mut ctx, &file_path, 1, 1);

        assert_eq!(ctx.summary.files_renamed, 0);

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_walk_and_rename_nonexistent_path() {
        let args = Args {
            dry_run: false,
            hidden: false,
            paths: vec!["/nonexistent/path/does/not/exist".to_string()],
            process_dangerous: false,
            recursive: false,
        };
        // Should handle nonexistent path gracefully
        walk_and_rename(args);
    }

    #[test]
    fn test_walk_and_rename_dry_run() {
        let temp_dir = std::env::temp_dir().join("test_walker_dry_run");
        let _ = fs::create_dir_all(&temp_dir);

        let file_with_colon = temp_dir.join("file:name.txt");
        fs::write(&file_with_colon, "test").expect("Failed to write test file");

        let args = Args {
            dry_run: true,
            hidden: false,
            paths: vec![file_with_colon.to_string_lossy().to_string()],
            process_dangerous: false,
            recursive: false,
        };

        walk_and_rename(args);

        // File should still exist with original name (dry run)
        assert!(file_with_colon.exists());

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_walk_and_rename_with_rename() {
        let temp_dir = std::env::temp_dir().join("test_walker_rename");
        let _ = fs::create_dir_all(&temp_dir);

        let file_with_colon = temp_dir.join("file:name.txt");
        fs::write(&file_with_colon, "test").expect("Failed to write test file");

        let args = Args {
            dry_run: false,
            hidden: false,
            paths: vec![file_with_colon.to_string_lossy().to_string()],
            process_dangerous: false,
            recursive: false,
        };

        walk_and_rename(args);

        // File should be renamed
        let renamed_file = temp_dir.join("file：name.txt");
        assert!(renamed_file.exists());

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_walk_and_rename_recursive() {
        let temp_dir = std::env::temp_dir().join("test_walker_recursive");
        let _ = fs::create_dir_all(&temp_dir);

        let subdir = temp_dir.join("subdir");
        let _ = fs::create_dir_all(&subdir);

        let file_with_colon = subdir.join("file:name.txt");
        fs::write(&file_with_colon, "test").expect("Failed to write test file");

        let args = Args {
            dry_run: false,
            hidden: false,
            paths: vec![temp_dir.to_string_lossy().to_string()],
            process_dangerous: false,
            recursive: true,
        };

        walk_and_rename(args);

        // File should be renamed
        let renamed_file = subdir.join("file：name.txt");
        assert!(renamed_file.exists());

        let _ = fs::remove_dir_all(&temp_dir);
    }
}
