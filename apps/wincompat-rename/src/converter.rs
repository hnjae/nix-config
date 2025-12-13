/// Mapping of illegal Windows characters to their full-width Unicode equivalents
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

/// Windows reserved filenames that cannot be used
const RESERVED_NAMES: &[&str] = &[
    "CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8",
    "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9",
];

#[must_use]
pub fn convert_filename(filename: &str) -> Option<String> {
    if filename.is_empty() || filename == "." || filename == ".." {
        return None;
    }

    let mut result = filename.to_owned();

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

/// Handles Windows reserved filenames by appending an underscore.
///
/// Windows reserves certain filenames like CON, PRN, AUX, NUL, COM1-9, LPT1-9.
/// This function detects these names and modifies them to be valid.
fn handle_reserved_names(filename: &str) -> String {
    let trimmed = filename.trim_end_matches(' ');

    for &reserved in RESERVED_NAMES {
        let reserved_lower = reserved.to_lowercase();
        let trimmed_lower = trimmed.to_lowercase();

        let cleaned = remove_illegal_chars_for_check(&trimmed_lower);

        if cleaned == reserved_lower {
            return format!("{trimmed}_");
        }

        if let Some(dot_pos) = trimmed.find('.') {
            // Use safe character boundary splitting
            let Some(name_part) = trimmed.get(..dot_pos) else {
                return filename.to_owned();
            };
            let name_lower = name_part.to_lowercase();
            let cleaned_name = remove_illegal_chars_for_check(&name_lower);

            if cleaned_name == reserved_lower {
                let reserved_len = reserved.len();
                if name_part.len() >= reserved_len {
                    let Some(prefix) = name_part.get(..reserved_len) else {
                        return filename.to_owned();
                    };
                    let Some(suffix) = name_part.get(reserved_len..) else {
                        return filename.to_owned();
                    };
                    let Some(ext) = trimmed.get(dot_pos.saturating_add(1)..) else {
                        return filename.to_owned();
                    };
                    return format!("{prefix}_{suffix}.{ext}");
                }
                let Some(ext) = trimmed.get(dot_pos.saturating_add(1)..) else {
                    return filename.to_owned();
                };
                return format!("{name_part}_.{ext}");
            }
        }
    }

    filename.to_owned()
}

/// Removes illegal characters from a string for checking purposes.
///
/// This is used internally to compare filenames against reserved names.
fn remove_illegal_chars_for_check(input: &str) -> String {
    let mut result = input.to_owned();
    for &(from, _) in ILLEGAL_CHARS_MAP {
        result = result.replace(from, "");
    }
    result
}

/// Replaces illegal Windows characters with their full-width Unicode equivalents.
///
/// This converts characters like `:` to `：`, `*` to `＊`, etc.
fn replace_illegal_chars(filename: &str) -> String {
    let mut result = filename.to_owned();

    for &(from, to) in ILLEGAL_CHARS_MAP {
        result = result.replace(from, to);
    }

    result
}

/// Removes trailing spaces from a filename.
///
/// Windows does not allow filenames to end with spaces.
fn remove_trailing_spaces(filename: &str) -> String {
    filename.trim_end_matches(' ').to_owned()
}

/// Converts trailing dots to full-width dots.
///
/// Windows does not allow filenames to end with a period.
/// This function replaces the last dot with a full-width period character.
fn convert_trailing_dots(filename: &str) -> String {
    if filename.is_empty() {
        return filename.to_owned();
    }

    let mut result = filename.to_owned();

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
        assert_eq!(
            convert_filename("file:name.txt"),
            Some("file：name.txt".to_string())
        );
        assert_eq!(
            convert_filename("my|file.doc"),
            Some("my｜file.doc".to_string())
        );
        assert_eq!(
            convert_filename("test<file>.txt"),
            Some("test＜file＞.txt".to_string())
        );
        assert_eq!(
            convert_filename("path/to\\file"),
            Some("path／to＼file".to_string())
        );
        assert_eq!(
            convert_filename("file*.txt"),
            Some("file＊.txt".to_string())
        );
        assert_eq!(
            convert_filename("file?.txt"),
            Some("file？.txt".to_string())
        );
        assert_eq!(
            convert_filename("file\"name\".txt"),
            Some("file＂name＂.txt".to_string())
        );
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
        assert_eq!(
            convert_filename("file.txt."),
            Some("file.txt．".to_string())
        );
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
        assert_eq!(
            convert_filename("파일:이름.txt"),
            Some("파일：이름.txt".to_string())
        );
        assert_eq!(
            convert_filename("ファイル|名前.txt"),
            Some("ファイル｜名前.txt".to_string())
        );
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
