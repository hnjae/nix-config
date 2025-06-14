{
  pkgs,
  pkgsUnstable,
  lib,
  config,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  # treesitter 을 시스템 단위로 관리하고 싶지 않으니, home-manager 모듈은 사용하지 말 것.
  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = lib.lists.concatLists [
      (with pkgsUnstable; [
        neovim
        neovim-remote
        code-minimap
        tree-sitter
        libsecret # to access org.freedesktop.Secret.Service in neovim config
      ])
      # (lib.lists.optionals baseHomeCfg.isDesktop (with pkgsUnstable; [
      #   # neovim-qt -- 한글 입력 별로. 사용하지 말것 (2024-04-18)
      #   # neovim-gtk -- 사용하지 말 것 (2023-12-21)
      # ]))
    ];

    xdg.desktopEntries."nvim" = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
      type = "Application";
      name = "Neovim";
      comment = "this should not be displayed";
      exec = ":";
      noDisplay = true;
    };

    home.sessionVariables = {
      EDITOR = lib.mkForce "nvim";
      VISUAL = "nvim";
    };

    home.shellAliases = {
      vi = "nvim";
    };
  };
}
