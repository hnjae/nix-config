{config, ...}: let
  genericHomeCfg = config.generic-home;
in {
  services.flatpak = {
    enable = genericHomeCfg.isDesktop;
    # remotes = [
    #   {
    #     name = "flathub";
    #     location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    #   }
    # ];
    update = {
      onActivation = false;
      auto = {
        enable = true;
        onCalendar = "daily"; # Default value
      };
    };
    uninstallUnmanagedPackages = true;

    # ~/.local/share/flatpak/overrides
    overrides = {
      "global" = {Context = {filesystems = ["/nix/store:ro"];};};
    };
  };
}
