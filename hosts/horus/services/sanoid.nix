{ ... }:
{
  services.sanoid = {
    enable = true;
    interval = "*-*-* 03:05:00";
    templates.ignore = {
      autoprune = false;
      autosnap = false;
      yearly = 0;
      monthly = 0;
      daily = 0;
      hourly = 0;
    };
  };
}
