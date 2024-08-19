{lib, ...}: {
  programs.gnupg.agent.enable = lib.mkOverride 999 true;
}
