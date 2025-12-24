# Run `wpctls status` to verify
# easyeffect 는 mono input 을 지원 안함. <https://github.com/wwmm/easyeffects/issues/1312>
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
            "node.description" = "Noise Canceling Source";
            "media.name" = "Noise Canceling Source";
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${pkgs.rnnoise-plugin.ladspa}/lib/ladspa/librnnoise_ladspa.so";
                  label = "noise_suppressor_mono";
                  control = {
                    "VAD Threshold (%)" = 10.0;
                    "VAD Grace Period (ms)" = 500;
                    "Retroactive VAD Grace (ms)" = 5;
                  };
                }
              ];
            };
            "audio.position" = [ "MONO" ];
            "capture.props" = {
              "node.name" = "capture.rnnoise_source";
              "node.passive" = true;
              "audio.rate" = 48000;
            };
            "playback.props" = {
              "node.name" = "rnnoise_source";
              "media.class" = "Audio/Source";
              "audio.rate" = 48000;
            };
          };
        }
      ];
    };
  };
}
