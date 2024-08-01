{pkgs, ...}: {
  environment.systemPackages = [
    #   fcitx5Package
    # pkgs.kime
  ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-mozc
      fcitx5-hangul
      # fcitx5-m17n
      fcitx5-lua
    ];
  };

  environment.variables = {
    "GLFW_IM_MODULE" = "ibus";
    "SDL_IM_MODULE" = "fcitx";
  };

  # environment.variables.XMODIFIERS = lib.mkForce "@im=kime";

  # # NOTE: unset these to use text-input protocol of wayland <2023-05-16>
  # GTK_IM_MODULE = "fcitx";
  # QT_IM_MODULE = "fcitx";
}
