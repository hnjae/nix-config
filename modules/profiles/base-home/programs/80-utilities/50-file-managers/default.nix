{ pkgsUnstable, ... }:
{
  imports = [
    ./lf
    ./pistol
    ./ranger
    ./yazi
  ];

  home.packages = [
    pkgsUnstable.superfile
  ];
}
