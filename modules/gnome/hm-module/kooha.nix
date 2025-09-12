{ pkgs, ... }:
{
  services.flatpak.packages = [
    "io.github.seadve.Kooha" # screen recorder
    # NOTE: 2025-01-06 checked
    "org.freedesktop.Platform.GStreamer.gstreamer-vaapi/${pkgs.hostPlatform.ubootArch}/23.08" # for kooha
  ];

  services.flatpak.overrides."io.github.seadve.Kooha" = {
    Environment = {
      "KOOHA_EXPERIMENTAL" = "1";
      "GST_VAAPI_ALL_DRIVERS" = "1";
    };
  };
}
