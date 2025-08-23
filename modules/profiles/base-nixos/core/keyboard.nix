{
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak_dh";
    # NOTE: 다음 옵션은 KDE 5.27 에서 타일링 버그를 만듦 shift:both_capslock_cancel <2023-12-07>
    options = builtins.concatStringsSep "," [
      # "altwin:swap_lalt_lwin"
      # "shift:both_capslock_cancel"
      # "korean:rctrl_hanja"
      # "ctrl:nocaps"
      "caps:backspace"
      "korean:ralt_hangul"
      "ctrl:swap_rwin_rctl"
    ];
  };
}
