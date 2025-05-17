/*
  README

  ### Bootstrap

  run `sudo tailscale up` and follow the instruction
*/
{ config, lib, ... }:
{
  services.tailscale = {
    enable = true;
    extraSetFlags = lib.lists.optional (config.base-nixos.role == "desktop") "--operator=hnjae";
  };
}
