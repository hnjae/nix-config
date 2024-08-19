{...}: {
  programs.plasma.configFile."kwinrc"."Wayland"."InputMethod" = {
    shellExpand = true;
    value = "/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop";
  };
}
