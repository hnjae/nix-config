const ILLEGAL_CHARS_MAP: &[(&str, &str)] = &[
    ("\\", "＼"),
    ("/", "／"),
    (":", "："),
    ("*", "＊"),
    ("?", "？"),
    ("\"", "＂"),
    ("<", "＜"),
    (">", "＞"),
    ("|", "｜"),
];

const RESERVED_NAMES: &[&str] = &[
    "CON", "PRN", "AUX", "NUL",
    "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
    "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9",
];

pub fn convert_filename(filename: &str) -> Option<String> {
    if filename.is_empty() || filename == "." || filename == ".." {
        return None;
    }

    let mut result = filename.to_string();

    result = handle_reserved_names(&result);
    result = replace_illegal_chars(&result);
    result = remove_trailing_spaces(&result);
    result = convert_trailing_dots(&result);

    if result == filename {
        None
    } else {
        Some(result)
    }
}

fn handle_reserved_names(filename: &str) -> String {
    let trimmed = filename.trim_end_matches(' ');

    for &reserved in RESERVED_NAMES {
        let reserved_lower = reserved.to_lowercase();
        let trimmed_lower = trimmed.to_lowercase();

        let cleaned = remove_illegal_chars_for_check(&trimmed_lower);

        if cleaned == reserved_lower {
            return format!("{}_", trimmed);
        }

        if let Some(dot_pos) = trimmed.find('.') {
            let name_part = &trimmed[..dot_pos];
            let name_lower = name_part.to_lowercase();
            let cleaned_name = remove_illegal_chars_for_check(&name_lower);

            if cleaned_name == reserved_lower {
                let reserved_len = reserved.len();
                if name_part.len() >= reserved_len {
                    let prefix = &name_part[..reserved_len];
                    let suffix = &name_part[reserved_len..];
                    return format!("{}_{}.{}", prefix, suffix, &trimmed[dot_pos + 1..]);
                } else {
                    return format!("{}_.{}", name_part, &trimmed[dot_pos + 1..]);
                }
            }
        }
    }

    filename.to_string()
}

fn remove_illegal_chars_for_check(s: &str) -> String {
    let mut result = s.to_string();
    for &(from, _) in ILLEGAL_CHARS_MAP {
        result = result.replace(from, "");
    }
    result
}

fn replace_illegal_chars(filename: &str) -> String {
    let mut result = filename.to_string();

    for &(from, to) in ILLEGAL_CHARS_MAP {
        result = result.replace(from, to);
    }

    result
}

fn remove_trailing_spaces(filename: &str) -> String {
    filename.trim_end_matches(' ').to_string()
}

fn convert_trailing_dots(filename: &str) -> String {
    if filename.is_empty() {
        return filename.to_string();
    }

    let mut result = filename.to_string();

    if result.ends_with('.') {
        result.pop();
        result.push('．');
    }

    result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_illegal_chars() {
        assert_eq!(convert_filename("file:name.txt"), Some("file：name.txt".to_string()));
        assert_eq!(convert_filename("my|file.doc"), Some("my｜file.doc".to_string()));
        assert_eq!(convert_filename("test<file>.txt"), Some("test＜file＞.txt".to_string()));
        assert_eq!(convert_filename("path/to\\file"), Some("path／to＼file".to_string()));
        assert_eq!(convert_filename("file*.txt"), Some("file＊.txt".to_string()));
        assert_eq!(convert_filename("file?.txt"), Some("file？.txt".to_string()));
        assert_eq!(convert_filename("file\"name\".txt"), Some("file＂name＂.txt".to_string()));
    }

    #[test]
    fn test_percent_not_converted() {
        assert_eq!(convert_filename("file%name.txt"), None);
    }

    #[test]
    fn test_trailing_spaces() {
        assert_eq!(convert_filename("file   "), Some("file".to_string()));
        assert_eq!(convert_filename("file.txt "), Some("file.txt".to_string()));
        assert_eq!(convert_filename("file  .txt"), None);
    }

    #[test]
    fn test_trailing_dots() {
        assert_eq!(convert_filename("file."), Some("file．".to_string()));
        assert_eq!(convert_filename("file..."), Some("file..．".to_string()));
        assert_eq!(convert_filename("file.txt."), Some("file.txt．".to_string()));
    }

    #[test]
    fn test_reserved_names() {
        assert_eq!(convert_filename("CON"), Some("CON_".to_string()));
        assert_eq!(convert_filename("con"), Some("con_".to_string()));
        assert_eq!(convert_filename("CON.txt"), Some("CON_.txt".to_string()));
        assert_eq!(convert_filename("con.TXT"), Some("con_.TXT".to_string()));
        assert_eq!(convert_filename("PRN"), Some("PRN_".to_string()));
        assert_eq!(convert_filename("AUX.log"), Some("AUX_.log".to_string()));
        assert_eq!(convert_filename("COM1"), Some("COM1_".to_string()));
        assert_eq!(convert_filename("LPT9.doc"), Some("LPT9_.doc".to_string()));
    }

    #[test]
    fn test_complex_cases() {
        assert_eq!(convert_filename("CON:.txt"), Some("CON_：.txt".to_string()));
        assert_eq!(convert_filename("CON."), Some("CON_．".to_string()));
    }

    #[test]
    fn test_already_converted() {
        assert_eq!(convert_filename("file：name.txt"), None);
        assert_eq!(convert_filename("my｜file.doc"), None);
    }

    #[test]
    fn test_special_cases() {
        assert_eq!(convert_filename("."), None);
        assert_eq!(convert_filename(".."), None);
        assert_eq!(convert_filename(""), None);
    }

    #[test]
    fn test_unicode_filenames() {
        assert_eq!(convert_filename("파일:이름.txt"), Some("파일：이름.txt".to_string()));
        assert_eq!(convert_filename("ファイル|名前.txt"), Some("ファイル｜名前.txt".to_string()));
    }

    #[test]
    fn test_normal_filenames() {
        assert_eq!(convert_filename("normal_file.txt"), None);
        assert_eq!(convert_filename("file-name_123.doc"), None);
    }

    #[test]
    fn test_reserved_name_conversion_order() {
        assert_eq!(convert_filename("CON."), Some("CON_．".to_string()));
        assert_eq!(convert_filename("PRN "), Some("PRN_".to_string()));
    }
}
