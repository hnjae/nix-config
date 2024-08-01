# WIP
{...}: {
  programs.chromium = {
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/chromium.nix
    enable = true;
    enablePlasmaBrowserIntegration = true;
  };
}
