{config, ...}: let
  baseHomeCfg = config.base-home;
in {
  services.flatpak = {
    enable = baseHomeCfg.isDesktop;
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
        onCalendar = "*-*-* 04:00:00";
      };
    };
    uninstallUnmanaged = true;
  };
}
