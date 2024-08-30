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

    # bindings https://github.com/wfxr/forgit 참고
    home.shellAliases = {
      # gcl = "git clone --depth 1";
      # gclr = "git clone --depth 1 --recurse-submodules --shallow-submodules";
      lg = "lazygit";
    };
    home.sessionVariables = {
      forgit_log = "glof";
    };

    programs.zsh.initExtra = ''
      . "${inputs.cgitc}/init.zsh"

      forgit_stash_show=gsts
      forgit_stash_push=gstP
      . "${pkgsUnstable.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh"
    '';

    programs.fish.interactiveShellInit = ''
      # . "${pkgsUnstable.fishPlugins.forgit}/share/fish/vendor_conf.d/forgit.plugin.fish"
    '';
  };
}
