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
    home.packages = lib.flatten [
      (with pkgsUnstable; [
        neovim
        neovim-remote
        code-minimap
        tree-sitter
        libsecret # to access org.freedesktop.Secret.Service in neovim config
      ])

      (lib.lists.optionals baseHomeCfg.isDesktop ([
        # pkgsUnstable.glrnvim
        # pkgs.gnvim
        # neovim-qt # 한글 입력 별로. 사용하지 말것 (2024-04-18)
        # neovim-gtk # IME 입력에서 도중 결과가 출력되지 않음 (2025-07-07)
        # neovide # IME 입력에서 도중 결과가 출력되지 않음 (2025-07-07)

        pkgs.page # use neovim as pager
        pkgs.nvimpager # use neovim as pager
      ]))
    ];

    default-app.text = "nvim";

    # xdg.desktopEntries."nvim" = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    #   type = "Application";
    #   name = "Neovim";
    #   comment = "this should not be displayed";
    #   exec = ":";
    #   noDisplay = true;
    # };

    home.sessionVariables = {
      EDITOR = lib.mkForce "nvim";
      VISUAL = "nvim";
    };
  };
}
