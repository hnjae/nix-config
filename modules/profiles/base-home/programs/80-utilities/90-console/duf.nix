{ pkgsUnstable, ... }:
{
  home.packages = [
    pkgsUnstable.duf # duf(du)
  ];
  home.shellAliases = {
    duf = "duf -theme ansi";
    # "duff" = "duf --only-mp '/,/mnt,/media/*,/boot,/srv/*'";
    "duff" = "duf --hide special";
  };
}
