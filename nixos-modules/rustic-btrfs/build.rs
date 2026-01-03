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
    eprintln!("build.rs: Starting build script");

    // Use pkg-config to find libbtrfsutil
    let lib = pkg_config::Config::new()
        .probe("libbtrfsutil")
        .expect("Failed to find libbtrfsutil via pkg-config");

    eprintln!("build.rs: Found libbtrfsutil at {:?}", lib.link_paths);

    // Explicitly add the link directive with KIND specified
    println!("cargo:rustc-link-lib=dylib=btrfsutil");
    eprintln!("build.rs: Added cargo:rustc-link-lib=dylib=btrfsutil");

    // Tell Cargo to rerun if build.rs changes
    println!("cargo:rerun-if-changed=build.rs");

    let out_path = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR not set"));

    // Get the include path from pkg-config
    let include_path = lib
        .include_paths
        .first()
        .expect("No include path found for libbtrfsutil");

    bindgen::Builder::default()
        .header_contents("wrapper.h", "#include <btrfsutil.h>")
        .clang_arg(format!("-I{}", include_path.display()))
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
