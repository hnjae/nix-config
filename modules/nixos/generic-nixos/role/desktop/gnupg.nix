{config, ...}: {
  programs.gnupg.agent.enable = config.generic-nixos.role == "desktop";
}
