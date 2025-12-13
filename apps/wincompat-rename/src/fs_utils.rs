use std::fs;
use std::path::Path;

#[cfg(unix)]
use std::os::unix::fs::MetadataExt as _;

#[must_use]
pub fn is_symlink(path: &Path) -> bool {
    fs::symlink_metadata(path).is_ok_and(|metadata| metadata.file_type().is_symlink())
}

#[must_use]
pub fn is_different_filesystem(path: &Path, base_dev: u64) -> bool {
    #[cfg(unix)]
    {
        fs::metadata(path).is_ok_and(|metadata| metadata.dev() != base_dev)
    }

    #[cfg(not(unix))]
    {
        let _ = (path, base_dev);
        false
    }
}

#[must_use]
pub fn get_device_id(path: &Path) -> Option<u64> {
    #[cfg(unix)]
    {
        fs::metadata(path).ok().map(|metadata| metadata.dev())
    }

    #[cfg(not(unix))]
    {
        let _ = path;
        Some(0)
    }
}

#[must_use]
pub fn is_hidden(path: &Path) -> bool {
    if let Some(filename) = path.file_name() {
        if let Some(name) = filename.to_str() {
            return name.starts_with('.');
        }
    }
    false
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn test_is_hidden() {
        assert!(is_hidden(Path::new(".hidden")));
        assert!(is_hidden(Path::new("/path/to/.hidden")));
        assert!(!is_hidden(Path::new("visible")));
        assert!(!is_hidden(Path::new("/path/to/visible")));
    }

    #[test]
    fn test_is_symlink() {
        let temp_file = std::env::temp_dir().join("test_regular_file.txt");
        fs::write(&temp_file, "test").unwrap();

        assert!(!is_symlink(&temp_file));

        let _ = fs::remove_file(&temp_file);
    }

    #[test]
    fn test_get_device_id() {
        let temp_dir = std::env::temp_dir();
        assert!(get_device_id(&temp_dir).is_some());
    }
}
