{pkgs, ...}: {
  services.xserver.displayManager.lightdm = {
    enable = false;
    greeters.slick = {
      enable = true;
      font.package = pkgs.pretendard;
      font.name = "Pretendard 11";
      # theme.package = pkgs.fluent-gtk-theme;
      # theme.name = "Fluent-Dark";
      # iconTheme.package = pkgs.icon-theme-fluent;
      # iconTheme.name = "Fluent-dark";
      cursorTheme.package = pkgs.bibata-cursors;
      cursorTheme.size = 48;
      cursorTheme.name = "Bibata-Modern-Ice";
      # https://github.com/linuxmint/slick-greeter
      extraConfig = ''
        xft-dpi=192
        enable-hidpi=on
        play-ready-sound=true
        screen-reader=false
        show-a11y=false
        draw-grid=true
      '';
    };
  };
}
