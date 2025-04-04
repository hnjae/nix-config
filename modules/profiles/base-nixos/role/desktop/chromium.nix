{ lib, config, ... }:
{
  # this affetcts vivaldi too
  programs.chromium = {
    enable = true;

    extensions = lib.flatten [
      "fmkadmapgofadopljbjfkapdkoienihi" # react-developer-tools
      "lmhkpmbekcpmknklioeibfkpmmfibljd" # redux-dev-tools

      "ddkjiahejlhfcafbddmgiahcphecmpfh" # ublock-origin-light
      # "lckanjgmijmafbedllaakclkaicjfmnk" # clearurls (manifest v2)
      "ldpochfccmkkmhdbclfhpagapcfdljkj" # decentraleyes

      "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic

      "hfjbmagddngcpeloejdejnfgbamkjaeg" # vimium-c
      (lib.lists.optional config.programs._1password.enable "aeblfdkhhhdcdjpifhhbdiojplfjncoa")
    ];
    homepageLocation = "about:blank";
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSuggestURL = "https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}";
    defaultSearchProviderSearchURL = "https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";

    extraOpts = {
      # Stateless
      "BrowserSignin" = 0; # disable browser sign-in
      "SyncDisabled" = true;
      "PasswordManagerEnabled" = false;
      "PasswordManagerPasskeysEnabled" = false;
      "ThirdPartyPasswordManagersAllowed" = false;

      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [
        "en-US"
      ];

      "BrowsingDataLifetime" = [
        {
          "data_types" = [
            "browsing_history"
            "download_history"
            "cookies_and_other_site_data"
            "cached_images_and_files"
            "password_signin"
            "autofill"
            "site_settings"
            "hosted_app_data"
          ];
          "time_to_live_in_hours" = 8;
        }
      ];
    };
  };
}
