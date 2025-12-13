use std::env;
use std::fs;
use std::io::Read as _;
use std::path::{Path, PathBuf};

/// List of directory names that are considered dangerous to rename.
///
/// These directories typically contain system files, configuration,
/// version control data, or other critical information that should
/// not be modified automatically.
const DANGEROUS_DIRNAMES: &[&str] = &[
    ".snapshots",
    ".zfs",
    ".config",
    ".git",
    ".git-crypt",
    ".github",
    ".ssh",
    ".vscode",
    ".claude",
    ".cache",
    ".ld.so",
    ".local",
    ".var",
    ".1password",
    ".cert",
    ".mozilla",
    ".pki",
    ".steam",
    ".dotnet",
    ".npm",
    ".ansible",
    ".deploy-gc",
    ".direnv",
    ".husky",
    ".venv",
    "__pycache__",
    "node_modules",
];

/// The signature that identifies a valid `CACHEDIR.TAG` file.
///
/// This signature is defined by the Cache Directory Tagging Specification.
const CACHEDIR_TAG_SIGNATURE: &str = "Signature: 8a477f597d28d172789f06886806bc55";

#[must_use]
pub fn is_dangerous_path(path: &Path) -> bool {
    if is_home_dotfile(path) {
        return true;
    }

    if is_dangerous_dirname(path) {
        return true;
    }

    if has_cachedir_tag(path) {
        return true;
    }

    false
}

/// Checks if a path is a dotfile directly in the home directory.
///
/// Returns `true` if the file is in the user's home directory and
/// its name starts with a dot (hidden file).
fn is_home_dotfile(path: &Path) -> bool {
    let Ok(home_dir) = env::var("HOME") else {
        return false;
    };

    let home_path = PathBuf::from(&home_dir);

    let Ok(abs_path) = path.canonicalize() else {
        return false;
    };

    if let Some(parent) = abs_path.parent()
        && parent == home_path
            && let Some(filename) = abs_path.file_name()
                && let Some(name) = filename.to_str() {
                    return name.starts_with('.');
                }

    false
}

/// Checks if a path's name matches any of the dangerous directory names.
///
/// Returns `true` if the directory name is in the predefined list of
/// dangerous directories (e.g., `.git`, `.ssh`, `node_modules`).
fn is_dangerous_dirname(path: &Path) -> bool {
    if let Some(filename) = path.file_name()
        && let Some(name) = filename.to_str() {
            return DANGEROUS_DIRNAMES.contains(&name);
        }
    false
}

/// Checks if a directory contains a valid CACHEDIR.TAG file.
///
/// CACHEDIR.TAG is a standard way to mark cache directories. This function
/// verifies that the directory contains a CACHEDIR.TAG file with the correct
/// signature as defined by the Cache Directory Tagging Specification.
///
/// # Returns
/// `true` if the directory contains a valid CACHEDIR.TAG file, `false` otherwise.
fn has_cachedir_tag(path: &Path) -> bool {
    if !path.is_dir() {
        return false;
    }

    let tag_path = path.join("CACHEDIR.TAG");
    if !tag_path.exists() {
        return false;
    }

    let Ok(mut file) = fs::File::open(&tag_path) else {
        return false;
    };

    let mut buffer = vec![0; CACHEDIR_TAG_SIGNATURE.len()];
    if file.read_exact(&mut buffer).is_err() {
        return false;
    }

    let content = String::from_utf8_lossy(&buffer);
    content == CACHEDIR_TAG_SIGNATURE
}

#[must_use]
pub fn check_collision(new_path: &Path) -> bool {
    new_path.exists()
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn test_dangerous_dirnames() {
        assert!(is_dangerous_dirname(Path::new(".git")));
        assert!(is_dangerous_dirname(Path::new("/some/path/.config")));
        assert!(is_dangerous_dirname(Path::new("node_modules")));
        assert!(is_dangerous_dirname(Path::new("/path/to/.ssh")));
        assert!(!is_dangerous_dirname(Path::new("normal_dir")));
        assert!(!is_dangerous_dirname(Path::new(".gitignore")));
    }

    #[test]
    fn test_cachedir_tag_detection() {
        let temp_dir = std::env::temp_dir().join("test_cachedir");
        let _ = fs::create_dir_all(&temp_dir);

        let tag_path = temp_dir.join("CACHEDIR.TAG");
        fs::write(&tag_path, CACHEDIR_TAG_SIGNATURE).unwrap();

        assert!(has_cachedir_tag(&temp_dir));

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_cachedir_tag_wrong_signature() {
        let temp_dir = std::env::temp_dir().join("test_cachedir_wrong");
        let _ = fs::create_dir_all(&temp_dir);

        let tag_path = temp_dir.join("CACHEDIR.TAG");
        fs::write(&tag_path, "Wrong signature").unwrap();

        assert!(!has_cachedir_tag(&temp_dir));

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_check_collision() {
        let temp_file = std::env::temp_dir().join("test_collision_file.txt");
        fs::write(&temp_file, "test").unwrap();

        assert!(check_collision(&temp_file));
        assert!(!check_collision(Path::new("/nonexistent/path/file.txt")));

        let _ = fs::remove_file(&temp_file);
    }

    #[test]
    fn test_is_dangerous_path_with_dangerous_dirname() {
        assert!(is_dangerous_path(Path::new(".git")));
        assert!(is_dangerous_path(Path::new("node_modules")));
        assert!(is_dangerous_path(Path::new(".ssh")));
    }

    #[test]
    fn test_is_dangerous_path_with_normal_path() {
        assert!(!is_dangerous_path(Path::new("normal_file.txt")));
        assert!(!is_dangerous_path(Path::new("/path/to/normal_dir")));
    }

    #[test]
    fn test_is_dangerous_path_with_cachedir_tag() {
        let temp_dir = std::env::temp_dir().join("test_dangerous_cachedir");
        let _ = fs::create_dir_all(&temp_dir);

        let tag_path = temp_dir.join("CACHEDIR.TAG");
        fs::write(&tag_path, CACHEDIR_TAG_SIGNATURE).unwrap();

        assert!(is_dangerous_path(&temp_dir));

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_is_home_dotfile_in_home() {
        let home_dir = std::env::var("HOME").ok();
        if let Some(home) = home_dir {
            let dotfile_path = std::path::PathBuf::from(&home).join(".bashrc");
            // Only test if we can create/check the file
            if dotfile_path.exists() {
                assert!(is_home_dotfile(&dotfile_path));
            }
        }
    }

    #[test]
    fn test_is_home_dotfile_not_dotfile() {
        let normal_file = std::env::temp_dir().join("normal_file.txt");
        fs::write(&normal_file, "test").unwrap();
        assert!(!is_home_dotfile(&normal_file));
        let _ = fs::remove_file(&normal_file);
    }

    #[test]
    fn test_is_home_dotfile_in_subdirectory() {
        let temp_dir = std::env::temp_dir().join("subdir");
        let _ = fs::create_dir_all(&temp_dir);
        let dotfile = temp_dir.join(".hidden");
        fs::write(&dotfile, "test").unwrap();

        assert!(!is_home_dotfile(&dotfile));

        let _ = fs::remove_file(&dotfile);
        let _ = fs::remove_dir(&temp_dir);
    }

    #[test]
    fn test_has_cachedir_tag_non_existent() {
        let non_existent = std::env::temp_dir().join("non_existent_dir_for_test");
        assert!(!has_cachedir_tag(&non_existent));
    }

    #[test]
    fn test_has_cachedir_tag_file_not_dir() {
        let temp_file = std::env::temp_dir().join("test_not_dir.txt");
        fs::write(&temp_file, "test").unwrap();
        assert!(!has_cachedir_tag(&temp_file));
        let _ = fs::remove_file(&temp_file);
    }

    #[test]
    fn test_is_dangerous_dirname_all_types() {
        // Test a few from each category
        // System configs
        assert!(is_dangerous_dirname(Path::new(".config")));
        // Version control
        assert!(is_dangerous_dirname(Path::new(".git")));
        // Package managers
        assert!(is_dangerous_dirname(Path::new("node_modules")));
        // Reserved
        assert!(is_dangerous_dirname(Path::new(".cache")));
    }
}
