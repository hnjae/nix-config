{
  config,
  pkgsUnstable,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      biome # linters, formatters

      # not working
      # pnpm-shell-completion
      # corepack_20 # Wrappers for npm, pnpm and Yarn via Node.js Corepack

      pnpm

      # current LTS (2024-02-29)
      nodejs_20

      # prettierd
      # nodePackages.typescript
      # nodePackages.typescript-language-server
      # nodePackages.ts-node

      # nodePackages.eslint
      # eslint_d

      nest-cli

      deno
      bun

      # vscode-langservers-extracted
      # dprint
    ];

    home.file.".npmrc" = {
      enable = true;
      text = ''
        cache="${config.xdg.stateHome}/npm"
      '';
    };

    # stateful.cowNodes = [
    #   {
    #     path = "${config.home.homeDirectory}/.pnpm-store";
    #     mode = "755";
    #     type = "dir";
    #   }
    #   {
    #     path = "${config.xdg.dataHome}/pnpm";
    #     mode = "755";
    #     type = "dir";
    #   }
    # {
    #   path = "${config.home.homeDirectory}/.yarn";
    #   mode = "755";
    #   type = "dir";
    # }
    # {
    #   path = "${config.xdg.dataHome}/yarn";
    #   mode = "755";
    #   type = "dir";
    # }
    # ];
  };
}
