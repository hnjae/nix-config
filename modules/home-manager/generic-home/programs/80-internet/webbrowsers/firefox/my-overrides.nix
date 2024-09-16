{lib, ...}: {
  programs.firefox.profiles.home.extraConfig = lib.mkAfter ''
    user_pref("extensions.pocket.enabled", true);
    user_pref("browser.compactmode.show", true);
  '';
}
