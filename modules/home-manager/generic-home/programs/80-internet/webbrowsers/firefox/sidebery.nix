{...}: {
  programs.firefox.profiles.home = {
    # extensions = [
    #   pkgs.nur.repos.bandithedoge.firefoxAddons.sidebery
    # ];

    # https://github.com/mbnuqw/sidebery/wiki/Firefox-Styles-Snippets-(via-userChrome.css)#dynamic-native-tabs
    # sidebery 에서 preface 를 🦊 로 설정해야한다.
    userChrome = ''
      /*
      hide header when using sideberry
      */
      #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] #sidebar-header {
        visibility: collapse;
      }

      /*
      disable native tab-bar when using sideberry
      */
      #main-window #titlebar {
        overflow: hidden;
        /* transition: height 0.3s 0.3s !important; */
      }
      /* Default state: Set initial height to enable animation */
      #main-window #titlebar { height: 3em !important; }
      #main-window[uidensity="touch"] #titlebar { height: 3.35em !important; }
      #main-window[uidensity="compact"] #titlebar { height: 2.7em !important; }
      /* Hidden state: Hide native tabs strip */
      #main-window[titlepreface*="🦊"] #titlebar { height: 0 !important; }
      /* Hidden state: Fix z-index of active pinned tabs */
      #wain-window[titlepreface*="🦊"] #tabbrowser-tabs { z-index: 0 !important; }
    '';
  };
}
