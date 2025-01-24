{ ... }:
{
  # /home/hnjae/.local/state/wireplumber/sm-settings
  # [sm-settings]
  # bluetooth.autoswitch-to-headset-profile=true

  services.pipewire.wireplumber.extraConfig."disable-hsp" = {
    # https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/bluetooth.html
    "monitor.bluez.properties" = {
      "bluez5.roles" = [
        "a2dp_sink"
        "a2dp_source"
        "bap_sink"
        "bap_source"
      ];
      "bluez5.codecs" = [
        "sbc_xq"
        "aac"
        "ldac"
        "aptx_hd"
        "aptx_ll"
        "aptx_ll_duplex"
        "lc3"
      ];
      "bluez5.a2dp.ldac.quality" = "sq"; # 660/606 kbps
      "bluez5.a2dp.aac.bitratemode" = 5; # VBR
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
