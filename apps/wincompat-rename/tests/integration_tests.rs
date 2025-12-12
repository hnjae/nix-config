use std::fs;
use std::path::PathBuf;
use wincompat_rename::{Args, walk_and_rename, convert_filename};

fn setup_test_dir(name: &str) -> PathBuf {
    let test_dir = std::env::temp_dir().join(format!("wincompat_test_{}", name));
    let _ = fs::remove_dir_all(&test_dir);
    fs::create_dir_all(&test_dir).unwrap();
    test_dir
}

fn cleanup_test_dir(dir: &PathBuf) {
    let _ = fs::remove_dir_all(dir);
}

#[test]
fn test_basic_file_rename() {
    let test_dir = setup_test_dir("basic");

    let file_path = test_dir.join("test:file.txt");
    fs::write(&file_path, "content").unwrap();

    let mut args = Args::new();
    args.paths = vec![file_path.to_str().unwrap().to_string()];
    args.dry_run = false;

    walk_and_rename(args);

    assert!(!file_path.exists());
    assert!(test_dir.join("test：file.txt").exists());

    cleanup_test_dir(&test_dir);
}

#[test]
fn test_dry_run_mode() {
    let test_dir = setup_test_dir("dry_run");

    let file_path = test_dir.join("test|file.txt");
    fs::write(&file_path, "content").unwrap();

    let mut args = Args::new();
    args.paths = vec![file_path.to_str().unwrap().to_string()];
    args.dry_run = true;

    walk_and_rename(args);

    assert!(file_path.exists());
    assert!(!test_dir.join("test｜file.txt").exists());

    cleanup_test_dir(&test_dir);
}

#[test]
fn test_reserved_name_rename() {
    let test_dir = setup_test_dir("reserved");

    let file_path = test_dir.join("CON.txt");
    fs::write(&file_path, "content").unwrap();

    let mut args = Args::new();
    args.paths = vec![file_path.to_str().unwrap().to_string()];
    args.dry_run = false;

    walk_and_rename(args);

    assert!(!file_path.exists());
    assert!(test_dir.join("CON_.txt").exists());

    cleanup_test_dir(&test_dir);
}

#[test]
fn test_collision_detection() {
    let test_dir = setup_test_dir("collision");

    let file1 = test_dir.join("test:file.txt");
    let file2 = test_dir.join("test：file.txt");
    fs::write(&file1, "content1").unwrap();
    fs::write(&file2, "content2").unwrap();

    let mut args = Args::new();
    args.paths = vec![file1.to_str().unwrap().to_string()];
    args.dry_run = false;

    walk_and_rename(args);

    assert!(file1.exists());
    assert!(file2.exists());

    cleanup_test_dir(&test_dir);
}

#[test]
fn test_recursive_rename() {
    let test_dir = setup_test_dir("recursive");
    let sub_dir = test_dir.join("subdir");
    fs::create_dir_all(&sub_dir).unwrap();

    let file1 = test_dir.join("file*.txt");
    let file2 = sub_dir.join("file?.txt");
    fs::write(&file1, "content1").unwrap();
    fs::write(&file2, "content2").unwrap();

    let mut args = Args::new();
    args.paths = vec![test_dir.to_str().unwrap().to_string()];
    args.recursive = true;
    args.dry_run = false;

    walk_and_rename(args);

    assert!(!file1.exists());
    assert!(!file2.exists());
    assert!(test_dir.join("file＊.txt").exists());
    assert!(sub_dir.join("file？.txt").exists());

    cleanup_test_dir(&test_dir);
}

#[test]
fn test_hidden_files() {
    let test_dir = setup_test_dir("hidden");

    let file1 = test_dir.join(".hidden:file.txt");
    fs::write(&file1, "content").unwrap();

    let mut args = Args::new();
    args.paths = vec![test_dir.to_str().unwrap().to_string()];
    args.recursive = true;
    args.hidden = true;
    args.dry_run = false;

    walk_and_rename(args);

    assert!(!file1.exists());
    assert!(test_dir.join(".hidden：file.txt").exists());

    cleanup_test_dir(&test_dir);
}

#[test]
fn test_hidden_files_skipped_by_default() {
    let test_dir = setup_test_dir("hidden_skip");

    let file1 = test_dir.join(".hidden:file.txt");
    fs::write(&file1, "content").unwrap();

    let mut args = Args::new();
    args.paths = vec![test_dir.to_str().unwrap().to_string()];
    args.recursive = true;
    args.hidden = false;
    args.dry_run = false;

    walk_and_rename(args);

    assert!(file1.exists());

    cleanup_test_dir(&test_dir);
}

#[test]
fn test_converter_comprehensive() {
    assert_eq!(convert_filename("normal.txt"), None);
    assert_eq!(convert_filename("file:name.txt"), Some("file：name.txt".to_string()));
    assert_eq!(convert_filename("file|name.txt"), Some("file｜name.txt".to_string()));
    assert_eq!(convert_filename("file*name.txt"), Some("file＊name.txt".to_string()));
    assert_eq!(convert_filename("file?name.txt"), Some("file？name.txt".to_string()));
    assert_eq!(convert_filename("file<name.txt"), Some("file＜name.txt".to_string()));
    assert_eq!(convert_filename("file>name.txt"), Some("file＞name.txt".to_string()));
    assert_eq!(convert_filename("file\\name.txt"), Some("file＼name.txt".to_string()));
    assert_eq!(convert_filename("file/name.txt"), Some("file／name.txt".to_string()));
    assert_eq!(convert_filename("file\"name.txt"), Some("file＂name.txt".to_string()));
}

#[test]
fn test_trailing_spaces_and_dots() {
    assert_eq!(convert_filename("file   "), Some("file".to_string()));
    assert_eq!(convert_filename("file.txt "), Some("file.txt".to_string()));
    assert_eq!(convert_filename("file."), Some("file．".to_string()));
    assert_eq!(convert_filename("file..."), Some("file..．".to_string()));
}

#[test]
fn test_reserved_names_comprehensive() {
    assert_eq!(convert_filename("CON"), Some("CON_".to_string()));
    assert_eq!(convert_filename("con"), Some("con_".to_string()));
    assert_eq!(convert_filename("PRN"), Some("PRN_".to_string()));
    assert_eq!(convert_filename("AUX"), Some("AUX_".to_string()));
    assert_eq!(convert_filename("NUL"), Some("NUL_".to_string()));
    assert_eq!(convert_filename("COM1"), Some("COM1_".to_string()));
    assert_eq!(convert_filename("COM9"), Some("COM9_".to_string()));
    assert_eq!(convert_filename("LPT1"), Some("LPT1_".to_string()));
    assert_eq!(convert_filename("LPT9"), Some("LPT9_".to_string()));
    assert_eq!(convert_filename("CON.txt"), Some("CON_.txt".to_string()));
    assert_eq!(convert_filename("com1.log"), Some("com1_.log".to_string()));
}
