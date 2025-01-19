{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.isDesktop {
    #
    # https://github.com/flathub/com.raggesilver.BlackBox/blob/master/com.raggesilver.BlackBox.json
    #
    # flatpak version's isuue: "Could not start dynamically linked executable:"
    # https://nix.dev/guides/faq#how-to-run-non-nix-executables
    # https://github.com/NixOS/nixpkgs/issues/282680 ``
    #
    # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/pkgs/applications/version-management/blackbox/default.nix#L58
    # services.flatpak.packages = [ "com.raggesilver.BlackBox" ];

    home.packages = [
      (pkgs.blackbox-terminal.override
        {
          sixelSupport = true;
        })
    ];
    dconf.settings = {
      "com/raggesilver/BlackBox" =
        {
          font = "Monospace 10.3";
          cursor-blink-mode = lib.hm.gvariant.mkUint32 2;
          # NOTE: round-corner 때문에 패딩을 더 여유롭게 할당 <2024-12-12>
          terminal-padding = lib.hm.gvariant.mkTuple [
            (lib.hm.gvariant.mkUint32 6)
            (lib.hm.gvariant.mkUint32 6)
            (lib.hm.gvariant.mkUint32 6)
            (lib.hm.gvariant.mkUint32 6)
          ];
          use-sixel = true;
          terminal-bell = false;
        }
        // (lib.attrsets.optionalAttrs (genericHomeCfg.base24.enable) {
          theme-light = "base24";
          theme-dark = "base24";
        });
    };
    # ~/.local/share/blackbox/schemes/gruvbox-light.json
    xdg.dataFile."blackbox/schemes/base24.json" = {
      enable = genericHomeCfg.base24.enable;
      source = config.scheme {templateRepo = ./resources/base24-blackbox;};
    };
  };
}
