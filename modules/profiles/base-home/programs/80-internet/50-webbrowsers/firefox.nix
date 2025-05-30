{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;
  profileName = "default";
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    systemd.user.tmpfiles.rules = [
      ''r "${config.home.homeDirectory}/.mozilla/firefox/${profileName}/search.json.mozlz4.*"''
    ];

    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      policies = {
        DisableFirefoxStudies = true;
        DisableTelemetry = true;
        DisableFeedbackCommands = true;
        DisablePocket = true;

        # stateless
        SanitizeOnShutdown = true;
        PrivateBrowsingModeAvailability = false;
        DontCheckDefaultBrowser = true;
        BlockAboutConfig = true;
        AppAutoUpdate = false;
        DisableSystemAddonUpdate = true;
        DisableFirefoxAccounts = true;
        DisableFormHistory = true;
        DisableMasterPasswordCreation = true;
        DisableProfileImport = true;
      };
      profiles."${profileName}" = {
        search.engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                  {
                    name = "size";
                    value = "200";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "size";
                    value = "200";
                  }
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "NixOS Wiki" = {
            urls = [ { template = "https://wiki.nixos.org/index.php?search={searchTerms}"; } ];
            icon = "https://wiki.nixos.org/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
          "Brave" = {
            urls = [ { template = "https://search.brave.com/search?q={searchTerms}&source=web"; } ];
            icon = "https://brave.com/static-assets/images/brave-logo-sans-text.svg";
            definedAliases = [ "@b" ];
          };
          "bing".metaData.hidden = true;
          "wikipedia".metaData.hidden = true;
        };
        bookmarks = {
          force = true;
          settings = [
            {
              name = "Nix sites";
              toolbar = true;
              bookmarks = [
                {
                  name = "homepage";
                  url = "https://nixos.org/";
                }
                {
                  name = "wiki";
                  tags = [
                    "wiki"
                    "nix"
                  ];
                  url = "https://wiki.nixos.org/";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
