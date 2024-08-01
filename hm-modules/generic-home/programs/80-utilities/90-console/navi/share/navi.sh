#!/bin/sh

CHEATS_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/navi/cheats/my_cheats/"

__ne_select() {
  term="$1"
  file="$(
    (
      fd "$term" "${CHEATS_DIR}" -e cheat -t f
    ) |
      sed -e "s|^$CHEATS_DIR||g" -e "s|\.cheat$||g" |
      sk --select-1 --exit-0 --preview='bat -l sh --color=always --italic-text=always --paging=never --decorations=never '"$CHEATS_DIR"'/{}.cheat' |
      awk -v path="$CHEATS_DIR" -v ext=".cheat" '{print path $0 ext}'
  )"

  echo "$file"
}

# navi-edit
ne() {
  if [ -n "$1" ]; then
    file="${CHEATS_DIR}/$1.cheat"
  else
    file="$(__ne_select ".")"
    [ -z "$file" ] && return
  fi

  # if [ "$file" == "new" ]; then
  #   printf "Enter: "
  #   read file
  #   [ -z "$file" ] && echo "O.k. I'll do nothing" && return
  # fi

  $EDITOR -- "$file"
}

# navi-show
ns() {
  if [ -n "$1" ] && [ -f "${CHEATS_DIR}/$1.cheat" ]; then
    file="${CHEATS_DIR}/$1.cheat"
  else
    [ -n "$1" ] && term="$1" || term="."

    file="$(__ne_select "$term")"
    [ -z "$file" ] && return
  fi

  # if [ "$file" == "new" ]; then
  #   printf "Enter: "
  #   read file
  #   [ -z "$file" ] && echo "O.k. I'll do nothing" && return
  #
  #   $EDITOR -- "$file"
  #   return
  # fi

  sed -e '/^\$/d' -- "$file" |
    bat -l sh --color=always --decorations=never
}
