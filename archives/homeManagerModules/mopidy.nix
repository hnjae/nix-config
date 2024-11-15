{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: let
  extensionPackages = with pkgs-unstable; [
    # backends
    mopidy-ytmusic
    mopidy-local

    # web
    mopidy-iris

    # frontends
    mopidy-mpd
    # mopidy-scrobbler
    # mopidy-mpris
  ];

  configFilePaths = "${config.xdg.configHome}/mopidy/mopidy.conf";

  mopidyEnv = pkgs-unstable.buildEnv {
    name = "mopidy-with-extensions-${pkgs-unstable.mopidy.version}";
    paths = pkgs.lib.closePropagation extensionPackages;
    pathsToLink = ["/${pkgs-unstable.mopidyPackages.python.sitePackages}"];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      makeWrapper ${pkgs-unstable.mopidy}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs-unstable.mopidyPackages.python.sitePackages}
    '';
  };
in {
  # services.mopidy = {
  #   enable = true;
  #   # package = pkgs-unstable.mopidy;
  #   settings = {
  #     file.enabled = false;
  #     mpd.hostname = "::";
  #     local.media_dir = "/home/hyunjae/Music";
  #   };
  # };

  systemd.user.services.mopidy = {
    Unit = {
      Description = "mopidy music player daemon";
      Documentation = ["https://mopidy.com/"];
      After = ["network.target" "sound.target"];
    };

    Service = {
      ExecStart = "${mopidyEnv}/bin/mopidy --config ${configFilePaths}";
    };

    Install.WantedBy = ["default.target"];
  };
  systemd.user.services.mopidy-scan = {
    Unit = {
      Description = "mopidy local files scanner";
      Documentation = ["https://mopidy.com/"];
      After = ["network.target" "sound.target"];
    };

    Service = {
      ExecStart = "${mopidyEnv}/bin/mopidy --config ${configFilePaths} local scan";
      Type = "oneshot";
    };

    Install.WantedBy = ["default.target"];
  };
}
