{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    dconf2nix
  ];

  # TODO: add followings <2024-11-15>
  # gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/mutter" = {
      experimental-features = ["scale-monitor-framebuffer"];
    };
  };
}
