use std::path::{Path, PathBuf};
use std::fs;
use std::io::Read;
use std::env;

const DANGEROUS_DIRNAMES: &[&str] = &[
    ".config",
    ".git",
    ".ssh",
    ".snapshots",
    "__pycache__",
    ".direnv",
    ".venv",
    ".ansible",
    ".husky",
    ".github",
    ".git-crypt",
    ".vscode",
    "node_modules",
];

const CACHEDIR_TAG_SIGNATURE: &str = "Signature: 8a477f597d28d172789f06886806bc55";

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

fn is_home_dotfile(path: &Path) -> bool {
    let Ok(home_dir) = env::var("HOME") else {
        return false;
    };

    let home_path = PathBuf::from(&home_dir);

    let Ok(abs_path) = path.canonicalize() else {
        return false;
    };

    if let Some(parent) = abs_path.parent() {
        if parent == home_path {
            if let Some(filename) = abs_path.file_name() {
                if let Some(name) = filename.to_str() {
                    return name.starts_with('.');
                }
            }
        }
    }

    false
}

fn is_dangerous_dirname(path: &Path) -> bool {
    if let Some(filename) = path.file_name() {
        if let Some(name) = filename.to_str() {
            return DANGEROUS_DIRNAMES.contains(&name);
        }
    }
    false
}

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
}
