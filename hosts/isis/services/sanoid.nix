{ ... }:
{
  services.sanoid = {
    enable = true;
    interval = "hourly";
    templates.ignore = {
      autoprune = false;
      autosnap = false;
      yearly = 0;
      monthly = 0;
      daily = 0;
      hourly = 0;
    };
    datasets = {
      "isis/safe" = {
        autoprune = true;
        autosnap = true;
        recursive = true;
        processChildrenOnly = true;
        daily = 7;
        hourly = 23;
        monthly = 0;
      };
      "isis/safe/home/hnjae/.cache" = {
        useTemplate = [ "ignore" ];
      };
    };
  };
}
