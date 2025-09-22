# Run `wpctls status` to verify
# 대신 easyeffect 사용
{
  pkgs,
  lib,
  config,
  ...
}:
{
  services.pipewire.extraConfig.pipewire = lib.mkIf (config.base-nixos.role == "desktop") {
    "99-deepfilternet" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "DeepFilter Noise Canceling Source";
            "media.name" = "DeepFilter Noise Canceling Source";
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "DeepFilter Mono";
                  plugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
                  label = "deep_filter_mono";
                  control = {
                    "Attenuation Limit (dB)" = 100;
                  };
                }
              ];
            };
            "audio.rate" = 48000;
            "audio.position" = [ "MONO" ];
            "capture.props" = {
              "node.passive" = true;
            };
            "playback.props" = {
              "media.class" = "Audio/Source";
            };
          };
        }
      ];
    };
  };
}
