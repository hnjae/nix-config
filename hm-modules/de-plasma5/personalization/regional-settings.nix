{...}: let
  metricLocale = "en_IE.UTF-8";
in {
  # Personalization - Regional Settings
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
