{...}: {
  services.flatpak.packages = [
    "io.github.seadve.Kooha" # screen recorder
    "org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08" # for kooha
  ];

  services.flatpak.overrides."io.github.seadve.Kooha" = {
    Environment = {
      "KOOHA_EXPERIMENTAL" = "1";
      "GST_VAAPI_ALL_DRIVERS" = "1";
    };
  };
}
