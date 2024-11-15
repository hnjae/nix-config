{
  config,
  self,
  lib,
  ...
}: {
  config = lib.mkIf (config.generic-nixos.role == "desktop") {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = config.generic-nixos.role == "desktop";
      polkitPolicyOwners = [config.users.users.${self.val.home.username}.name];
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
  };
}
