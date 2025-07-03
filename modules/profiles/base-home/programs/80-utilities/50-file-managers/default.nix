{ pkgsUnstable, ... }:
{
  imports = [
    # ./lf
    ./pistol
  ];

  home.packages = [
    # pkgsUnstable.superfile
    pkgsUnstable.glow
    pkgsUnstable.yazi
  ];
}
