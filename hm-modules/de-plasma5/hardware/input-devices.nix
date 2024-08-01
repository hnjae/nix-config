{...}: {
  # Hardware - Input Devices - Keyboard
  programs.plasma.configFile."kxkbrc" = {
    "Layout"."LayoutList".value = "us";
    "Layout"."VariantList".value = "colemak_dh";
  };
}
