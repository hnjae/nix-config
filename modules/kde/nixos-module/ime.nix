{ pkgs, lib, ... }:
{
  config = {
    # IME
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-hangul
          fcitx5-lua
          fcitx5-mozc-ut
          # fcitx5-anthy
          # fcitx5-m17n
        ];
      };
    };

    environment.systemPackages = [
      (lib.hiPrio (
        pkgs.makeDesktopItem {
          name = "org.fcitx.fcitx5-migrator";
          desktopName = "This should not be displayed.";
          exec = ":";
          noDisplay = true;
        }
      ))
      (lib.hiPrio (
        pkgs.makeDesktopItem {
          name = "org.fcitx.Fcitx5";
          desktopName = "This should not be displayed.";
          exec = ":";
          noDisplay = true;
        }
      ))
    ];
  };
}
