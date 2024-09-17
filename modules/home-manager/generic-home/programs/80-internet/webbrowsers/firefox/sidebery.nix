{pkgs, ...}: {
  programs.firefox.profiles.home = {
    extensions = [
      pkgs.nur.repos.bandithedoge.firefoxAddons.sidebery
    ];

    # https://github.com/mbnuqw/sidebery/wiki/Firefox-Styles-Snippets-(via-userChrome.css)#dynamic-native-tabs
    userChrome = ''
      #main-window #titlebar {
        overflow: hidden;
        transition: height 0.3s 0.3s !important;
      }
      /* Default state: Set initial height to enable animation */
      #main-window #titlebar { height: 3em !important; }
      #main-window[uidensity="touch"] #titlebar { height: 3.35em !important; }
      #main-window[uidensity="compact"] #titlebar { height: 2.7em !important; }
      /* Hidden state: Hide native tabs strip */
      #main-window[titlepreface*="XXX"] #titlebar { height: 0 !important; }
      /* Hidden state: Fix z-index of active pinned tabs */
      #main-window[titlepreface*="XXX"] #tabbrowser-tabs { z-index: 0 !important; }
    '';
  };
}
