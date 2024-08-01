{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      git-open
      git-crypt

      #
      lazygit

      # tig
    ];
    services.flatpak.packages = lib.mkIf genericHomeCfg.isDesktop [
      # opensource git client
      # "com.jetpackduba.Gitnuro"
      # "org.gnome.gitg"
      # "com.github.Murmele.Gittyup"
      # "de.philippun1.turtle"
      # "org.kde.kommit"
    ];

    home.shellAliases = {
      g = "git";
      gcl = "git clone --depth 1";
      gclr = "git clone --depth 1 --recurse-submodules --shallow-submodules";
      lg = "lazygit";
    };
  };
}
