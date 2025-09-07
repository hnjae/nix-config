/*
  README

  ### Bootstrap

  run `sudo tailscale up` and follow the instruction
*/
{ config, lib, ... }:
let
  cfg = config.base-nixos;
in
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkIf (cfg.role == "desktop") (lib.mkOverride 999 "client");
    extraSetFlags = lib.lists.optional (config.base-nixos.role == "desktop") "--operator=hnjae";
  };
}
