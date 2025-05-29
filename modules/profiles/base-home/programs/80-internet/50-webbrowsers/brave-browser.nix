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
    programs.chromium = {
      enable = true;
      # NOTE: ungoogled-chromium 은 extensions 설치가 안된다.
      # package = pkgs.chromium;
      package = pkgs.brave.override {
        commandLineArgs = lib.escapeShellArgs [
          "--wayland-text-input-version=3"
        ];
      };
      dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
      extensions = [
        { id = "fmkadmapgofadopljbjfkapdkoienihi"; } # react-developer-tools
        { id = "lmhkpmbekcpmknklioeibfkpmmfibljd"; } # redux-dev-tools

        { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # ublock-origin-light
        { id = "lckanjgmijmafbedllaakclkaicjfmnk"; } # clearurls
        # { id = "njdfdhgcmkocbgbhcioffdbicglldapd"; } # localcdn
        { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # decentraleyes

        { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # vimium-c
        { id = "mdjildafknihdffpkfmmpnpoiajfjnjd"; } # Consent-O-Matic

        { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1password
      ];
    };
  };
}
