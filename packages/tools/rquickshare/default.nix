{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
# writeScript,
# curl,
# jq,
# common-updater-scripts,
}:
# The raw package that fetches and extracts the Plex RPM. Override the source
# and version of this derivation if you want to use a Plex Pass version of the
# server, and the FHS userenv and corresponding NixOS module should
# automatically pick up the changes.
appimageTools.wrapType2 rec {
  version = "0.5.0";
  pname = "rquickshare";

  src = fetchurl {
    url = "https://github.com/Martichou/${pname}/releases/download/v${version}/r-quick-share_${version}_amd64_GLIBC-2.31.AppImage";
    sha256 = "";
  };

  meta = with lib; {
    homepage = "https://github.com/Martichou/rquickshare";
    # sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    description = "Rust implementation of NearbyShare/QuickShare from Android for Linux.";
  };
}
