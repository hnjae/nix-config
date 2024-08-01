{...}: let
  inherit (builtins) concatStringsSep;
  wmclassMaker = classes: (concatStringsSep "|" (map (cls: "(" + cls + ")") classes));
  classThunderbird = {
    "wmclass".value = wmclassMaker ["org\\.mozilla\\.Thunderbird"];
    "wmclassmatch".value = 3;
  };
in {
  plasma6.windowRules = [
    {
      uuid = "86a57c4c-90f3-4c58-af9d-598d10dd23f4";
      description = "minsize-thunderbird-calendar";
      Match =
        classThunderbird
        // {
          "title".value = "Calendar - Mozilla Thunderbird";
          "titlematch".value = 1;
        };
      Rule = {
        "minsize".value = "968x532";
        "minsizerule".value = 2;
      };
    }
    {
      uuid = "0cf3f9c3-d726-41f2-906c-9fb58e8fc477";
      description = "minsize-thunderbird";
      Match =
        classThunderbird
        // {
          "title".value = "^(?!Calendar - Mozilla Thunderbird$).*";
          "titlematch".value = 3;
        };
      Rule = {
        "minsize".value = "546x508";
        "minsizerule".value = 2;
      };
    }
  ];
}
