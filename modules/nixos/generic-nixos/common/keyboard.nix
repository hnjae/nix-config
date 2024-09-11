_: {
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak_dh";
    # NOTE: 다음 옵션은 KDE 5.27 에서 타일링 버그를 만듦 shift:both_capslock_cancel <2023-12-07>
    options = builtins.concatStringsSep "," [
      # "shift:both_capslock_cancel"
      "altwin:swap_lalt_lwin"
      "korean:ralt_hangul"
      "caps:backspace"
    ];
    # "ctrl:nocaps"
  };
}
