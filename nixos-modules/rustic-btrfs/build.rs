//! Build script for generating Btrfs FFI bindings.
//!
//! This script generates Rust bindings for libbtrfsutil using bindgen.
//! The bindings are written to the `OUT_DIR` for inclusion in the library.

// Build scripts are allowed to panic on errors - it's expected behavior for build failures
#![allow(clippy::expect_used)]
#![allow(clippy::missing_docs_in_private_items)]

use std::env;
use std::path::PathBuf;

fn main() {
    println!("cargo:rustc-link-lib=btrfsutil");

    let out_path = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR not set"));

    bindgen::Builder::default()
        .header_contents("wrapper.h", "#include <btrfsutil.h>")
        .allowlist_function("btrfs_util_.*") // All btrfs_util functions
        .allowlist_type("btrfs_util_.*") // All btrfs_util types
        .allowlist_var("BTRFS_UTIL_.*") // All btrfs_util constants
        .rustified_enum("btrfs_util_error")
        .layout_tests(false)
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file(out_path.join("btrfs_bindings.rs"))
        .expect("Couldn't write bindings");
}
