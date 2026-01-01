use bindgen;

fn main() {
    println!("cargo:rustc-link-lib=btrfsutil");

    bindgen::Builder::default()
        .header_contents("wrapper.h", "#include <btrfsutil.h>")
        .allowlist_function("btrfs_util_.*") // All btrfs_util functions
        .allowlist_type("btrfs_util_.*") // All btrfs_util types
        .allowlist_var("BTRFS_UTIL_.*") // All btrfs_util constants
        .rustified_enum("btrfs_util_error")
        .layout_tests(false)
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file(concat!(env!("OUT_DIR"), "/btrfs_bindings.rs"))
        .expect("Couldn't write bindings");
}
