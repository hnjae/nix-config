{lib, ...}: {
  programs.firefox.profiles.home.extraConfig = lib.mkAfter ''
    user_pref("extensions.pocket.enabled", true);

    /** compact mode **/
    user_pref("browser.uidensity", 1);

    /** native titlebar **/
    user_pref("browser.tabs.inTitlebar", 0);
  '';
}
