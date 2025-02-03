/*
  ## README

  ### Bootstrap

  run `sudo tailscale up` and follow the instruction
*/
{ ... }:
{
  services.tailscale = {
    enable = true;
  };
}
