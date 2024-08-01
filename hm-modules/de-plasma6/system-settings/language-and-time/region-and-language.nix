{...}: let
  # NOTE:
  # en_CA: Y-M-D hour:min P.M.
  # en_IE: D/M/Y hour:min
  metricLocale = "en_IE.UTF-8";
  # iso8601Locale = "en_SE.UTF-8";
  # timeLocale = "en_CA.UTF-8";
in {
  programs.plasma.configFile."plasma-localerc" = {
    "Formats" = {
      "LANG".value = "en_US.UTF-8";
      "LC_NUMERIC".value = "en_US.UTF-8";
      "LC_MONETARY".value = "en_US.UTF-8";
      "LC_TIME".value = metricLocale;
      "LC_MEASUREMENT".value = metricLocale;
      "LC_PAPER".value = metricLocale;
      "LC_ADDRESS".value = metricLocale;
      "LC_NAME".value = metricLocale;
      "LC_TELEPHONE".value = metricLocale;
    };
  };
}
