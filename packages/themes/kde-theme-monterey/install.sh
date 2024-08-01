#!/usr/bin/env bash

# out="${out:-$HOME/.local/share}"
THEME_NAME=Monterey

# AURORAE_DIR="$out/share/aurorae/themes"
SCHEMES_DIR="$out/share/color-schemes"
PLASMA_DIR="$out/share/plasma/desktoptheme"
# LOOKFEEL_DIR="$out/share/plasma/look-and-feel"
KVANTUM_DIR="$out/share/Kvantum"
LATTE_DIR="$out/share/latte"
SDDM_DIR="$out/share/sddm/themes"
# SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
WALLPAPER_DIR="$out/share/wallpapers"
# SRC_DIR="."

DIRS=(
  # "$AURORAE_DIR"
  # "$LOOKFEEL_DIR"
  "${WALLPAPER_DIR}"
  "$SCHEMES_DIR"
  "$PLASMA_DIR"
  "$KVANTUM_DIR"
  "$LATTE_DIR"
  "$SDDM_DIR"
)

for dir_ in "${DIRS[@]}"; do
  [ ! -d "${dir_}" ] && mkdir -p "${dir_}"
done

install() {
  local name="${1}"
# local color="${2}"

  # cp -r "aurorae/"*                     "${AURORAE_DIR}"
  # cp -r "${SRC_DIR}/wallpaper/${name}"             "${WALLPAPER_DIR}"
  cp -r "wallpaper/"*                   "${WALLPAPER_DIR}"
  cp -a "Kvantum/"*                     "${KVANTUM_DIR}"
  cp -a "color-schemes/"*               "${SCHEMES_DIR}"
  cp -a "plasma/desktoptheme/${name}"*  "${PLASMA_DIR}"
  cp -a "plasma/desktoptheme/icons"     "${PLASMA_DIR}/${name}"
  cp -a "plasma/desktoptheme/icons"     "${PLASMA_DIR}/${name}-dark"
  # cp -a "plasma/look-and-feel/"*        "${LOOKFEEL_DIR}"
  cp -a "latte-dock/"*                  "${LATTE_DIR}"
  cp -a "sddm/Monterey" "${SDDM_DIR}"
}

install "${THEME_NAME}"
