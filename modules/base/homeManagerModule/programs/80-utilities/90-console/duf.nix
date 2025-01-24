{ pkgsUnstable, ... }:
{
  home.packages = [
    pkgsUnstable.duf # duf(du)
  ];
  home.shellAliases = {
    duf = "duf -theme ansi";
    "duff" = "duf --only-mp '/,/boot,/srv/*'";
  };
}
