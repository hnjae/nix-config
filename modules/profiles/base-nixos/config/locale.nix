{ ... }:
{
  i18n =
    let
      metricLocale = "en_IE.UTF-8";
    in
    {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        # LANGUAGE = "en_US:en:C";
        # BUG: NixOS 25.05 does not support Above syntax; glibc 컴파일에 에러가 발생

        LC_NUMERIC = "en_US.UTF-8"; # e.g.) 150,392.2
        LC_MESSAGES = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        # NOTE: en_se in KDE does not seems to exists in glib
        /*
          NOTE:
            * en_SE: Y-M-D hour:min

            * en_CA: Y-M-D hour:min P.M.
            * en_IE: D/M/Y hour:min
            * en_DK: D/M/Y hour.min
        */
        LC_TIME = metricLocale;
        LC_PAPER = metricLocale;
        LC_TELEPHONE = metricLocale;
        LC_MEASUREMENT = metricLocale;
        LC_ADDRESS = metricLocale;
        LC_NAME = metricLocale;
      };

      extraLocales = [
        "C.UTF-8/UTF-8"
      ];
    };
}
