#!/usr/bin/env bash

# out="${out:-$HOME/.local/share}"

# AURORAE_DIR="$out/share/aurorae/themes"
SCHEMES_DIR="$out/share/color-schemes"
PLASMA_DIR="$out/share/plasma/desktoptheme"
# PLASMOIDS_DIR="$out/share/plasma/plasmoids"
# LOOKFEEL_DIR="$out/share/plasma/look-and-feel"
KVANTUM_DIR="$out/share/Kvantum"
SDDM_DIR="$out/share/sddm/themes"
# SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
# WALLPAPER_DIR="$out/share/wallpapers"
# SRC_DIR="."

DIRS=(
  # "$AURORAE_DIR"
  "$SCHEMES_DIR"
  "$PLASMA_DIR"
  # "$LOOKFEEL_DIR"
  "$KVANTUM_DIR"
  "$SDDM_DIR"
  # "${WALLPAPER_DIR}"
  # "$PLASMOIDS_DIR"
)

for dir_ in "${DIRS[@]}"; do
  [ ! -d "${dir_}" ] && mkdir -p "${dir_}"
done

install() {
  # local name="${1}"
# local color="${2}"

  # cp -r "aurorae/"*                     "${AURORAE_DIR}"
  # cp -r "wallpaper/"*   "${WALLPAPER_DIR}"
  # cp -a "Kvantum/dark_header_version"*        "${KVANTUM_DIR}"
  cp -a "Kvantum/"*        "${KVANTUM_DIR}"
  rm -rf  "${KVANTUM_DIR}/dark_header_version"

  cp -a "color-schemes/"*        "${SCHEMES_DIR}"
  cp -a "plasma/desktoptheme/"*  "${PLASMA_DIR}"
  # cp -a "plasma/plasmoids/"*     "${PLASMOIDS_DIR}"
  # cp -a "plasma/desktoptheme/icons" "${PLASMA_DIR}/${name}"
  # cp -a "plasma/desktoptheme/icons" "${PLASMA_DIR}/${name}-alt"
  # cp -a "plasma/desktoptheme/icons" "${PLASMA_DIR}/${name}-dark"
  # cp -a "plasma/look-and-feel/"*        "${LOOKFEEL_DIR}"
  cp -a "sddm/Fluent"    "${SDDM_DIR}"
  cp -a "sddm/backgrounds/background-round.png"    "${SDDM_DIR}/Fluent/background.png"
}

install
