_: {
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak_dh";
    # NOTE: 다음 옵션은 KDE 5.27 에서 타일링 버그를 만듦 shift:both_capslock_cancel <2023-12-07>
    # options = "altwin:swap_lalt_lwin,korean:ralt_hangul,caps:backspace";
    options = "korean:ralt_hangul,caps:backspace";
    # xkbOptions = "altwin:swap_lalt_lwin,korean:ralt_hangul,caps:backspace,shift:both_capslock_cancel";
    # xkbOptions = ctrl:nocaps,shift:both_capslock_cancel
  };
}
