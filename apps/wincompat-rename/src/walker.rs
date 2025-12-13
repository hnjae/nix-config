use crate::cli::Args;
use crate::converter::convert_filename;
use crate::fs_utils::{get_device_id, is_different_filesystem, is_hidden, is_symlink};
use crate::output::{ProgressBar, Summary, print_rename, print_summary, print_warning};
use crate::safety::{check_collision, is_dangerous_path};
use std::fs;
use std::path::{Path, PathBuf};

struct WalkContext {
    base_dev: Option<u64>,
    args: Args,
    summary: Summary,
}

pub fn walk_and_rename(args: Args) {
    let paths = args.paths.clone();
    let recursive = args.recursive;

    let mut ctx = WalkContext {
        base_dev: None,
        args,
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
            process_single_path(&mut ctx, &path);
        }
    }

    print_summary(&ctx.summary);
}

fn process_directory_recursive(ctx: &mut WalkContext, dir: &Path) {
    let mut all_paths = Vec::new();
    collect_paths(ctx, dir, &mut all_paths);

    all_paths.sort_by_key(|b| std::cmp::Reverse(b.components().count()));

    if ctx.args.recursive {
        let mut progress = ProgressBar::new(all_paths.len());
        for (idx, path) in all_paths.iter().enumerate() {
            process_single_path(ctx, path);
            progress.update(idx + 1);
        }
        progress.finish();
    }
}

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

    if let Some(base_dev) = ctx.base_dev {
        if is_different_filesystem(dir, base_dev) {
            return;
        }
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
            ctx.summary.skipped_dangerous += 1;
            continue;
        }

        if let Some(base_dev) = ctx.base_dev {
            if is_different_filesystem(&path, base_dev) {
                print_warning(&format!(
                    "SKIPPED \"{}\" (different filesystem)",
                    path.display()
                ));
                ctx.summary.skipped_filesystem += 1;
                continue;
            }
        }

        collected.push(path.clone());

        if path.is_dir() {
            collect_paths(ctx, &path, collected);
        }
    }
}

fn process_single_path(ctx: &mut WalkContext, path: &Path) {
    if is_symlink(path) {
        return;
    }

    if !ctx.args.process_dangerous && is_dangerous_path(path) {
        print_warning(&format!("SKIPPED \"{}\" (dangerous path)", path.display()));
        ctx.summary.skipped_dangerous += 1;
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
        ctx.summary.skipped_exists += 1;
        return;
    }

    if ctx.args.dry_run {
        print_rename(filename_str, &new_filename);
    } else {
        match fs::rename(path, &new_path) {
            Ok(()) => {
                print_rename(filename_str, &new_filename);
                if path.is_dir() {
                    ctx.summary.dirs_renamed += 1;
                } else {
                    ctx.summary.files_renamed += 1;
                }
            }
            Err(e) => {
                print_warning(&format!(
                    "Failed to rename \"{filename_str}\" → \"{new_filename}\": {e}"
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

        fs::write(temp_dir.join("file1.txt"), "test").unwrap();
        fs::write(temp_dir.join("file2.txt"), "test").unwrap();

        let mut ctx = WalkContext {
            base_dev: get_device_id(&temp_dir),
            args: Args::new(),
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
        fs::write(&file_path, "test").unwrap();

        let mut ctx = WalkContext {
            base_dev: get_device_id(&temp_dir),
            args: Args::new(),
            summary: Summary::new(),
        };

        process_single_path(&mut ctx, &file_path);

        assert_eq!(ctx.summary.files_renamed, 0);

        let _ = fs::remove_dir_all(&temp_dir);
    }
}
