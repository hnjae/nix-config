{
  config,
  pkgsUnstable,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = with pkgsUnstable; [
      biome # linters, formatters

      # not working
      # pnpm-shell-completion
      # corepack_20 # Wrappers for npm, pnpm and Yarn via Node.js Corepack

      pnpm

      # current LTS (2024-02-29)
      nodejs_20
      nest-cli

      deno
      bun
    ];

    home.file.".npmrc" = {
      enable = true;
      text = ''
        cache="${config.xdg.stateHome}/npm"
      '';
    };
  };
}
