{
  config,
  lib,
  inputs,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      git-open
      git-crypt
      git-lfs

      #
      lazygit

      # tig
    ];

    services.flatpak.packages = lib.mkIf (genericHomeCfg.isDesktop && genericHomeCfg.installTestApps) [
      # opensource git client
      # "com.jetpackduba.Gitnuro" # gpl3, jvm
      # "com.github.Murmele.Gittyup" # mit
      # "org.kde.kommit" # gpl3
      # "de.philippun1.turtle" # gpl3, libadwaita
      # "org.gnome.gitg" # gpl2
    ];

    # bindings https://github.com/wfxr/forgit 참고
    home.shellAliases = {
      lg = "lazygit";
    };
    home.sessionVariables = {
    };

    programs.zsh.initExtra = ''
      # cgitc configures forgit aliases
      . "${inputs.cgitc}/init.zsh"

      . "${pkgsUnstable.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh"
    '';
  };
}
