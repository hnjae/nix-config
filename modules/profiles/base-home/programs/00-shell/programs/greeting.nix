{ pkgs, lib, ... }:
let
  cmd = builtins.concatStringsSep " " [
    ''PF_INFO="ascii title os host kernel uptime memory shell"''
    ''"${pkgs.pfetch-rs}/bin/pfetch"''
  ];
in
{
  programs.zsh.initContent = lib.mkBefore cmd;
  programs.bash.initExtra = cmd;
  programs.fish.functions.fish_greeting.body = cmd;
}
