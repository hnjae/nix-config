# TODO: 그냥 smart 모니터링으로 대체 가능하지 않을까. <2025-12-03>
{ config, lib, ... }:
let
  cfg = config.base-nixos;
in
{
  services.nvme-rs = {
    enable = lib.mkDefault (cfg.hostType == "baremetal");
  };
}
