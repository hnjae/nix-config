{lib, ...}: {
  programs.firefox.profiles.home.extraConfig = lib.mkAfter ''
    user_pref("extensions.pocket.enabled", true);
  '';
}
