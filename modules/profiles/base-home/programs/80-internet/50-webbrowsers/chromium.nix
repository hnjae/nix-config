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
    # home.packages = [ pkgs.chromium ];

    programs.chromium = {
      enable = true;
      package = pkgs.chromium; # NOTE: ungoogled-chromium 은 extensions 설치가 안된다.
      dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
      commandLineArgs = [
        "--enable-wayland-ime"
        "--wayland-text-input-version=3"
      ];
      extensions = [
        { id = "fmkadmapgofadopljbjfkapdkoienihi"; } # react-developer-tools
        { id = "lmhkpmbekcpmknklioeibfkpmmfibljd"; } # redux-dev-tools

        { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # ublock-origin-light
        { id = "lckanjgmijmafbedllaakclkaicjfmnk"; } # clearurls
        # { id = "njdfdhgcmkocbgbhcioffdbicglldapd"; } # localcdn
        { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # decentraleyes

        { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # vimium-c
        { id = "mdjildafknihdffpkfmmpnpoiajfjnjd"; } # Consent-O-Matic
      ];
    };
  };
}
