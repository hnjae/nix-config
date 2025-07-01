{ pkgs, ... }:
{
  config = {
    # IME
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        plasma6Support = true;
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
  };
}
