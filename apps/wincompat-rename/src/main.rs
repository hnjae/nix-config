use wincompat_rename::{parse_args, walk_and_rename};

fn main() {
    let args = parse_args();
    walk_and_rename(args);
}
