{
  config,
  lib,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop) {
    home.packages = builtins.concatLists [
      (with pkgsUnstable; [
        tgpt # support openai, ollma https://github.com/aandrew-me/tgpt
        gtt # can use chatgpt to translate <https://github.com/eeeXun/gtt>
        # oterml # ollama client - not in nixpkgs 2024-08-07

        jan # GUI
      ])
    ];
  };
}
