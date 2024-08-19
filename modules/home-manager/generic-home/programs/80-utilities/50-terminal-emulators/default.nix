# https://www.arewesixelyet.com/
# NOTE: wayland-input-protocl 의 한계로 GTK, QT 를 안쓰는 터미널은 한글 입력시 잦은 애로 사항이 있음. <23.11>
#
{...}: {
  imports = [
    # ./blackbox
    # ./termite
    # ./alacritty
    # ./kitty
    ./foot
    ./wezterm
    ./warp-terminal
  ];
}
# NOTE:
# rio: terminal built with rust, no fontconfig, sixel support
# darktile: no wayland support
# contour: wayland 에서 폰트 렌더링이 이상함.

