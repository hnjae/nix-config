{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (config.base-nixos.role == "desktop") {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = config.base-nixos.role == "desktop";
      polkitPolicyOwners = [ "hnjae" ];
    };

    environment.etc."1password/custom_allowed_browsers" = {
      text = ''
        vivaldi-bin
        librewolf
      '';
      # NOTE: 0444 로 는 작동 안됨. 왜지. <2024-07-01>
      # https://1password.community/discussion/120954/how-the-browser-integration-works
      mode = "0755";
    };

    # polkit-bypass-1password.
    security.polkit.extraConfig = ''
      polkit.addRule(function (action, subject) {
        if (
          action.id == 'com.1password.1Password.unlock' ||
          action.id == 'com.1password.1Password.authorizeCLI' ||
          action.id == 'com.1password.1Password.authorizeSshAgent'
        ) {
          return polkit.Result.YES;
        }
      });
    '';

    home-manager.sharedModules = [
      (
        { config, lib, ... }:
        {
          home.sessionVariables = {
            SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
          };
          home.file.".ssh/config".text = lib.mkOrder 1 ''
            Host *
              IdentityAgent = "~/.1password/agent.sock"
          '';
          # programs.ssh.matchBlocks = {
          #   "*" = {
          #     IdentityAgent = "~/.1password/agent.sock";
          #   };
          # };
        }
      )
      {
        xdg.configFile."autostart/1password.desktop" = {
          enable = true;
          # KDE Panel 실행 기다리기 위해 sleep 필요 <NixOS 23.11, KDE 5.27.1>
          text = ''
            [Desktop Entry]
            Categories=Office;
            Comment=Password manager and secure wallet
            Exec=sh -c 'sleep 1 && GTK_USE_PORTAL=0 1password --silent'
            Icon=1password
            MimeType=x-scheme-handler/onepassword;
            Name=1Password
            StartupWMClass=1Password
            Terminal=false
            Type=Application
          '';
          # Exec=sh -c 'sleep 1 && unset GTK_USE_PORTAL && GTK_IM_MODULE=xim 1password --silent'
          # Exec=sh -c 'sleep 1 && GTK_USE_PORTAL=0 1password --silent --enable-features=UseOzonePlatform --ozone-platform-hint=auto --enable-wayland-ime'
        };
      }
      (
        { config, ... }:
        {
          stateful.nodes = [
            {
              path = "${config.xdg.configHome}/op";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.xdg.configHome}/1Password";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.home.homeDirectory}/.1password";
              mode = "700";
              type = "dir";
            }
          ];
        }
      )
    ];
  };
}
