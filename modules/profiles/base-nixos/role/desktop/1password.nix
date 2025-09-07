{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (config.base-nixos.role == "desktop") {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "hnjae" ];
      # package = (
      #   pkgs._1password-gui.overrideAttrs (_: {
      #     preferLocalBuild = true;
      #     # HACK: Temporary fix for NixOS 25.05
      #     preFixup = ''
      #       makeShellWrapper $out/share/1password/1password $out/bin/1password \
      #         "''${gappsWrapperArgs[@]}" \
      #         --suffix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]} \
      #         --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.udev ]} \
      #         --add-flags "\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}"
      #     '';
      #
      #   })
      # );
    };

    environment.systemPackages = [
      # TODO: KDE Wayland Session 에서 className `1Password` 로 켜짐. kwin titlebar 에서 generic wayland icon 으로 표기됨. <NixOS 25.05; KDE 6.3>
      # NOTE: 1password-gui 의 빌트인 아이콘은 svg 가 아니라 png 로 되어있음. <NixOS 25.05>
      # (pkgs.runCommandLocal "1password-gui-wayland-icon-fix" { } (
      #   let
      #     icon = "${pkgs.marwaita-icons}/share/icons/Marwaita/scalable/apps/1password.svg";
      #   in
      #   ''
      #
      #     mkdir -p "$out/share/icons/hicolor/scalable/apps/"
      #
      #     cp --reflink=auto "${icon}" "$out/share/icons/hicolor/scalable/apps/1Password.svg"
      #     cp --reflink=auto "${icon}" "$out/share/icons/hicolor/scalable/apps/1password.svg"
      #   ''
      # ))
    ];

    environment.etc."1password/custom_allowed_browsers" = {
      text = ''
        vivaldi-bin
        librewolf
        zen
        flatpak-session-helper
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
      {
        # home.sessionVariables = {
        #   SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
        # };
      }
      {
        xdg.configFile."autostart/1password.desktop" = {
          enable = true;
          # KDE Panel 실행 기다리기 위해 sleep 필요 <NixOS 23.11, KDE 5.27.1>
          text = ''
            [Desktop Entry]
            Categories=Office;
            Comment=Password manager and secure wallet
            Exec=sh -c 'sleep 1 && 1password --silent'
            Icon=1password
            MimeType=x-scheme-handler/onepassword;
            Name=1Password
            StartupWMClass=1Password
            Terminal=false
            Type=Application
          '';
          # Exec=sh -c 'sleep 1 && GTK_USE_PORTAL=0 1password --silent'
          # Exec=sh -c 'sleep 1 && GTK_USE_PORTAL=0 1password --silent --enable-features=UseOzonePlatform --ozone-platform-hint=auto --enable-wayland-ime'
        };
      }
    ];
  };
}
