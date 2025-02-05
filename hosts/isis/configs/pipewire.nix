{ ... }:
{
  # /home/hnjae/.local/state/wireplumber/sm-settings
  # [sm-settings]
  # bluetooth.autoswitch-to-headset-profile=true

  /*
    NOTE:
      run `wpcl status` and `wpctl inspect <node>` to get status and properties
  */

  services.pipewire.wireplumber.extraConfig."disable-hsp" = {
    # https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/bluetooth.html
    "monitor.bluez.properties" = {
      "bluez5.roles" = [
        # disable hsp profiles
        "a2dp_sink"
        "a2dp_source"
        "bap_sink"
        "bap_source"
      ];
      "bluez5.codecs" = [
        # Disable sbc and sbc_xq
        "aac"
        "ldac"
        "aptx"
        "aptx_hd"
        "aptx_ll"
        "aptx_ll_duplex"
      ];
      "bluez5.a2dp.ldac.quality" = "sq"; # sq: standard quality 660/606 kbps
      /*
        NOTE:
          aac.bitratemode = 0 (CBR) or 2 -- 5 (VBR) causes stuttering on some devices (FILL CC Pro 2) <2025-02-04>
      */
      "bluez5.a2dp.aac.bitratemode" = 1;
    };
  };

  # services.pipewire.wireplumber.extraConfig."wh-1000xm4" = {
  #   "monitor.bluez.rules" = [
  #     {
  #       matches = [
  #         {
  #           # any matching WH-1000XM4
  #           # run `pactl list` to get attributes
  #           "device.name" = "~bluez_card.*";
  #           "device.product.id" = "0x0d58";
  #           "device.vendor.id" = "usb:054c";
  #         }
  #       ];
  #       actions = {
  #         update-props = {
  #           # "bluez5.roles" = ["hfp_hf" "a2dp_sink" "a2dp_source"];
  #           "bluez5.codecs" = ["aac" "ldac"];
  #           "bluez5.roles" = ["a2dp_sink" "a2dp_source"];
  #           "bluez5.a2dp.ldac.quality" = "mq";
  #           "bluez5.a2dp.aac.bitratemode" = 5;
  #         };
  #       };
  #     }
  #   ];
  # };
}
