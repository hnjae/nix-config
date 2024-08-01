{
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  # ※ nixpkgs 버전을 sixel 지원하게 수정하는게 더 빠를듯.

  # NOTE: cursor 깜박이는걸 끌 수가 없음. <Version 0.14.0>

  #
  # https://github.com/flathub/com.raggesilver.BlackBox/blob/master/com.raggesilver.BlackBox.json

  # flatpak version's isuue: "Could not start dynamically linked executable:"
  # https://nix.dev/guides/faq#how-to-run-non-nix-executables
  # https://github.com/NixOS/nixpkgs/issues/282680 ``

  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/pkgs/applications/version-management/blackbox/default.nix#L58

  config = lib.mkIf genericHomeCfg.isDesktop {
    services.flatpak.packages = [
      # requires flatpak version to support sixel
      "com.raggesilver.BlackBox"
    ];
  };
}
