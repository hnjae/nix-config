pkgs:
(pkgs.writeText "ignore.txt" ''
  /.*

  /Downloads
  /dwhelper
  /git
  /temp

  !/.var
  !/.var/app
  /.var/app/*/.ld.so
  /.var/app/*/cache

  /.var/app/*/config/*[Cc]ache
  /.var/app/*/config/**/*[Cc]ache
  /.var/app/*/config/**/CacheStorage
  /.var/app/*/data/*[Cc]ache
  /.var/app/*/data/**/*[Cc]ache

  /.var/app/*/config/fcitx
  /.var/app/*/config/ibus
  /.var/app/*/config/pulse/cookie
  /.var/app/*/config/trashrc
  /.var/app/*/config/user-dirs.dirs
  /.var/app/*/data/recently-used.xbel
  /.var/app/*/data/user-places.xbel*

  /.var/app/com.usebottles.bottles/data/bottles/bottles/*/drive_c/users/*/AppData/Local/Temp
  /.var/app/org.kde.ark/data/ark/ark_recentfiles
  /.var/app/org.kde.dolphin/config/session
  /.var/app/org.kde.gwenview/data/gwenview/recentfolders
  # /.var/app/org.kde.kontact/data/akonadi_*/*/tmp
  /.var/app/org.kde.kontact/data/kontact/kontact_recentfiles
  /.var/app/org.kde.kwrite/data/kwrite/anonymous.katesession
  /.var/app/org.kde.kwrite/data/kwrite/sessions
  /.var/app/org.kde.okular/data/okular/docdata
  /.var/app/org.libreoffice.LibreOffice/config/libreoffice/4/user/backup
  /.var/app/org.libreoffice.LibreOffice/config/libreoffice/4/user/extensions/tmp
  /.var/app/org.onlyoffice.desktopeditors/data/onlyoffice/desktopeditors/recents.xml

  !/.mozilla
  /.mozilla/firefox/Crash Reports
  /.mozilla/firefox/firefox-mpris
  /.mozilla/firefox/*/datareporting
  /.mozilla/firefox/*/saved-telemetry-pings
  /.mozilla/firefox/*/storage/default/*/cache
  /.mozilla/firefox/*/weave/logs
  /.mozilla/firefox/*/sessionstore-backups
  !/.config
  /.config/*
  !/.config/chromium
  /.config/chromium/**/*[Cc]ache
  /.config/chromium/*[Cc]ache
  /.config/chromium/**/CacheStorage
  !/.config/BraveSoftware
  /.config/BraveSoftware/Brave-Browser/**/*[Cc]ache
  /.config/BraveSoftware/Brave-Browser/*[Cc]ache
  /.config/BraveSoftware/Brave-Browser/**/CacheStorage
  !/.config/sh.cider.genten
  /.config/sh.cider.genten/**/*[Cc]ache
  /.config/sh.cider.genten/*[Cc]ache
  !/.cert
  !/.pki

  # Linux
  .Trash-*
  .nfs*
  .fuse_hidden*
  .snapshots

  # KDE
  .directory

  # macOS
  .DS_Store
  ._*
  .localized

  # MS Windows
  [Tt]humbs.db
  [Dd]esktop.ini
  ?RECYCLE.BIN

  # Android
  .temp
  .thumbnails
  .trashed-*

  # Temporary files
  *.parts
  *.part
  *.crdownload

  # Vim
  *.swp
  *~

  # Direnv
  .direnv

  # NodeJS
  node_modules

  # Python (NO CACHEDIR.TAG inside)
  .venv
  __pycache__
  *.py[oc]

  # ZSH
  *.zwc

  # KdenLive
  # kdenlive/**/proxy
  # kdenlive/**/audiothumbs
  # kdenlive/**/preview
  # kdenlive/**/sequences
  # kdenlive/**/videothumbs
  # kdenlive/**/workfiles

  # Things should be excluded by .gitignore
  # dist
  # build

  # vi:ft=gitignore
'')
