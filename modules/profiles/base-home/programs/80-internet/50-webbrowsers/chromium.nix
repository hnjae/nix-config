{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.base-home;
in
{
  config = lib.mkIf (cfg.isDesktop && pkgs.stdenv.isLinux) {
    # stateful.nodes = [
    #   {
    #     path = "${config.xdg.configHome}/chromium";
    #     mode = "700";
    #     type = "dir";
    #   }
    # ];

    programs.chromium = {
      enable = true;
      package = pkgs.chromium; # ungoogled-chromium 은 extensions 설치가 안된다.
      dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
      extensions = [
        { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # ublock-origin-light
        { id = "lckanjgmijmafbedllaakclkaicjfmnk"; } # clearurls
        { id = "njdfdhgcmkocbgbhcioffdbicglldapd"; } # localcdn
        { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # vimium-c
        { id = "mdjildafknihdffpkfmmpnpoiajfjnjd"; } # Consent-O-Matic
      ];
    };
  };
}
