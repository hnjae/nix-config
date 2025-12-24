#!/bin/env bash

STARTS_WITH=(
  "accessibility" # accessibility- / accessibility_
  "accessories"
  "applet"      # applet_ / applets-
  "application" # application- / applications-
  "user"        # user_* /user-* / users*
  "config-"
  "cs-"
  "csd-"
  "preferences"
  "utilities-"
  "system-"
  "stock_"
  "tools-"
  "input-"
  "internet-"
  "workspace-" # workspace-overview / workspace-switcher-
  "software-"
  "package" # package / package_
  "multimedia-"
  "media-"
  "mail" # mail- / mail_
  "help" # help- / help_
  "graphics-"
  "indicator-"
  "camera-"
  "bluetooth-"
)

declare -A KEEP_ICONS=(
  # ["cups"]=1
  # ["ddcui"]=1
  # ["thunderbolt"]=1
  ["Appstore"]=1
  ["Dictionary"]=1
  ["Terminal"]=1
  ["access"]=1
  ["accessibility"]=1
  ["activity-log-manager"]=1
  ["addressbook"]=1
  ["adjust-colors"]=1
  ["administration"]=1
  ["agenda"]=1
  ["agent"]=1
  ["alarm-clock"]=1
  ["alarm-timer"]=1
  ["appointment"]=1
  ["appointment-soon"]=1
  ["background"]=1
  ["bluetooth"]=1
  ["bluetooth-inactive"]=1
  ["browser"]=1
  ["browser-help"]=1
  ["browser-tor"]=1
  ["bt-loog"]=1
  ["bug"]=1
  ["calc"]=1
  ["calculator"]=1
  ["calendar"]=1
  ["calls"]=1
  ["camera"]=1
  ["clock"]=1
  ["clocks"]=1
  ["color"]=1
  ["color-calibate"]=1
  ["color-management"]=1
  ["color-pick"]=1
  ["color-picker"]=1
  ["colors"]=1
  ["colour"]=1
  ["configuration_section"]=1
  ["configurator"]=1
  ["contact"]=1
  ["contact-editor"]=1
  ["contacts"]=1
  ["cookie"]=1
  ["date"]=1
  ["dates"]=1
  ["desktop"]=1
  ["desktop-profiler"]=1
  ["devhelp"]=1
  ["dialer"]=1
  ["dialog-info"]=1
  ["dialog-information"]=1
  ["dialog-password"]=1
  ["password"]=1
  ["passwords"]=1
  ["password-manager"]=1
  ["passwordmanager"]=1
  ["dict"]=1
  ["dictionary"]=1
  ["dock"]=1
  ["document-open-recent"]=1
  ["document-print-preview"]=1
  ["documentation"]=1
  ["e-mail"]=1
  ["edit-clear"]=1
  ["edit-find"]=1
  ["edit-paste"]=1
  ["edit-urpm-sources"]=1
  ["equaliser"]=1
  ["extension-manager"]=1
  ["extensions"]=1
  ["file-manager"]=1
  ["filemanager-actions"]=1
  ["fonts"]=1
  ["help"]=1
  ["image-missing"]=1
  ["imap"]=1
  ["lock"]=1
  ["lock-screen"]=1
  ["login"]=1
  ["login-photo"]=1
  ["panel"]=1
  ["podcast"]=1
  ["printer"]=1
  ["scanner"]=1
  ["screenruler"]=1
  ["screensaver"]=1
  ["software-properties"]=1
  ["software"]=1
  ["screensaver"]=1
  ["repository"]=1
  ["screenruler"]=1
  ["switchuser"]=1
  ["system-switch-user"]=1
  ["systemsettings"]=1
  ["systemtray"]=1
  ["terminal"]=1
  ["text-editor"]=1
  ["thermal-monitor"]=1
  ["time"]=1
  ["time-admin"]=1
  ["update-manager"]=1
  ["update-notifier"]=1
  ["userinfo"]=1
  ["users"]=1
  ["wallpaper"]=1
  ["wayland"]=1
  ["x-terminal-emulator"]=1
  ["xorg"]=1
  ["xterm"]=1
)

replace_symlink() {
  file_="${1}"
  if [ -h "$file_" ]; then
    # Use GNU readlink
    target="$(readlink -f "$file_")"
    rm "$file_"

    # cp --reflink=always "$target" "$file_"
    [ -f "$target" ] && ln "$target" "$file_"
  fi
}

should_remove() {
  file_="${1}"
  filename="$(basename -- "$1")"
  # filestem="${filename##*/}"
  filestem="${filename%.*}"

  if [ "${KEEP_ICONS[${filestem}]}" = "1" ]; then
    replace_symlink "$file_"
    echo 0
    return
  fi

  for name in "${STARTS_WITH[@]}"; do
    if [[ $filestem == "$name"* ]]; then
      replace_symlink "$file_"
      echo 0
      return
    fi
  done

  echo 1
}

rm_files=()
for file_ in "./"*; do
  if [ "$(should_remove "$file_")" -eq 1 ]; then
    rm_files+=("$file_")
  fi
done

# 마지막에 파일 삭제
for file_ in "${rm_files[@]}"; do
  rm "$file_"
done

# for file_ in "./"*; do
#   # true if file exists (symbolic link 가 missing 인 경우 제거)
#   if [ ! -e "$file_" ]; then
#     rm "$file_"
#   fi
# done
