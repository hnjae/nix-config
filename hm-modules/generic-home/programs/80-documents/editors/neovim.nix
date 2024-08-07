{
  pkgs,
  pkgsUnstable,
  lib,
  config,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = lib.lists.concatLists [
      (with pkgsUnstable; [
        neovim
        neovim-remote
        code-minimap
        tree-sitter
        libsecret # to access org.freedesktop.Secret.Service in neovim config
      ])
      # (lib.lists.optionals genericHomeCfg.isDesktop (with pkgsUnstable; [
      #   # neovim-qt -- 한글 입력 별로. 사용하지 말것 (2024-04-18)
      #   # neovim-gtk -- 사용하지 말 것 (2023-12-21)
      # ]))
    ];

    xdg.desktopEntries."nvim" =
      lib.mkIf (
        genericHomeCfg.isDesktop && pkgs.stdenv.isLinux
      ) {
        type = "Application";
        name = "Neovim";
        comment = "this should not be displayed";
        exec = ":";
        noDisplay = true;
      };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    home.shellAliases = {vi = "nvim";};

    # treesitter 을 시스템 단위로 관리하고 싶지 않으니, home-manager 모듈은 사용하지 말 것.
    programs.neovim = {
      enable = false;
      # extraPackages = with pkgsUnstable; [ tree-sitter nodePackages.neovim ];
      plugins = with pkgsUnstable.vimPlugins; [
        nvim-treesitter.withAllGrammars
        sniprun
      ];
      package = pkgsUnstable.neovim-unwrapped;
      # package = pkgsUnstable.neovim;
    };
    stateful.cowNodes = [
      {
        path = "${config.xdg.dataHome}/nvim";
        mode = "700";
        type = "dir";
      }
    ];

    python = {
      enable = true;
      pythonPackages = [
        "pynvim"

        # for coq
        # "pynvim_pp"
        # "msgpack"
        # "std2"
        # "pyyaml"
      ];
    };
  };
}
