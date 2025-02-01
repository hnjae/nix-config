{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # NOTE: lsd does not use terminal colos in some case <2023-10-05; lsd v0.23.1>
    eza # lsd 는 ANSI color 안써서 eza 쓰자. <2022-?>
  ];
  home.shellAliases = {
    ls = builtins.concatStringsSep " " [
      "eza"
      "--group"
      "--links"
      "--time-style long-iso"
      "--color=automatic"
      "--icons=never"
      "--mounts"
      "--extended"
    ];
    l = builtins.concatStringsSep " " [
      "eza"
      "--group"
      "--links"
      "--time-style long-iso"
      "--color=always"
      "--icons=always"
      "--git"
      "--mounts"
      "--extended"
      # "--group-directories-first"
    ];
    ll = "l --long";
    la = "l -a";
    lt = "l --tree";
    lla = "l -la";
    etr = "eza --tree --git-ignore";
  };
}
