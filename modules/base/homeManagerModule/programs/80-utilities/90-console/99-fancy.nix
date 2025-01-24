# 딱히 필요는 없는데 fancy 한 친구들
{
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
{
  home.packages = builtins.concatLists [
    (with pkgsUnstable; [
      # ## SYSTEM Fetch:
      # neofetch: neofetch is dead
      # nerdfetch: POSIX Shell, does not count nix package
      # freshfetch: rust, does not count nix package
      # hyfetch: wraps fastfetch or neofetch and color logo
      # screenfetch: old-fashioned, shell
      # macchina: fast, rust, does not display distro logo
      # pfetch-rs: fast, rust
      fastfetch # C, count nix pckage
      # pfetch-rs # ''PF_INFO="ascii title os host kernel uptime shell de wm editor cpu memory palette"''
      # macchina # rust

      cpufetch
      ipfetch

      onefetch # git
      # neo
    ])
    (lib.lists.optionals pkgs.stdenv.isLinux [ pkgsUnstable.ramfetch ])
  ];
}
