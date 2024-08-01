{
  dirs = {
    "755" = [
      ".local/share/baloo"
      ".local/share/ark"
      ".local/share/gwenview"
      ".local/share/kactivitymanagerd"
      ".local/share/kcookiejar"
      ".local/share/kded5"
      ".local/share/klipper"
      ".local/share/kscreen"
      ".local/share/okular"
      ".local/share/plasma-systemmonitor"
      ".local/share/RecentDocuments"
      ".local/share/libkunitconversion"
      ".local/share/sddm"
    ];
    "700" = [".local/share/mime"];
  };
  files = {
    "600" = [
      # 아래 파일은 덮어쓰기 되어 symbolic link 유지가 안됨
      # ".local/share/recently-used.xbel"
      ".local/share/krunnerstaterc"
      ".local/share/user-places.xbel"
    ];
    "644" = [];
  };
}
