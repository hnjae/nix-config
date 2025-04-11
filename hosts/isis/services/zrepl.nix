# NOTE: <https://zrepl.github.io/configuration/jobs.html>
{
  services.zrepl.enable = true;

  services.zrepl.settings.jobs = [
    {
      name = "isis-snap"; # must not change
      type = "snap";
      filesystems = {
        "isis/safe<" = true;
        "isis/safe/home/hnjae/.cache<" = false;
      };
      snapshotting = {
        type = "periodic";
        prefix = "zrepl_";
        interval = "1h";
        timestamp_format = "iso-8601";
      };
      pruning = {
        keep = [
          {
            type = "grid";
            grid = "1x1h(keep=all) | 24x1h | 7x1d | 4x7d";
            regex = "^(zrepl|autosnap)_.*";
          }
          {
            type = "last_n";
            count = 7;
            regex = "^(zrepl|autosnap)_.*";
          }
          {
            type = "regex";
            negate = true;
            regex = "^(zrepl|autosnap)_.*";
          }
        ];
      };
    }
  ];
}
