{
  runCommandLocal,
  symlinkJoin,
  caffeine-ng,
  fluent-icon-theme,
  ...
}: let
  icon = {
    light = {
      full = "${fluent-icon-theme}/share/icons/Fluent/symbolic/status/caffeine-cup-full-symbolic.svg";
      empty = "${fluent-icon-theme}/share/icons/Fluent/symbolic/status/caffeine-cup-empty-symbolic.svg";
    };
    dark = {
      full = "${fluent-icon-theme}/share/icons/Fluent-dark/symbolic/status/caffeine-cup-full-symbolic.svg";
      empty = "${fluent-icon-theme}/share/icons/Fluent-dark/symbolic/status/caffeine-cup-empty-symbolic.svg";
    };
  };

  iconPkg = runCommandLocal "caffeine-ng-icon" {} ''
    mkdir -p "$out/share/icons/breeze/status/64/"
    cp --reflink=auto \
      "${icon.light.full}" \
        "$out/share/icons/breeze/status/64/caffeine-cup-full.svg"
    cp --reflink=auto \
      "${icon.light.empty}" \
        "$out/share/icons/breeze/status/64/caffeine-cup-empty.svg"

    mkdir -p "$out/share/icons/breeze-dark/status/64/"
    cp --reflink=auto \
      "${icon.dark.full}" \
        "$out/share/icons/breeze-dark/status/64/caffeine-cup-full.svg"
    cp --reflink=auto \
      "${icon.dark.empty}" \
        "$out/share/icons/breeze-dark/status/64/caffeine-cup-empty.svg"

    paths=(
      "$out/share/icons/breeze/status/48/"
      "$out/share/icons/breeze/status/32/"
      "$out/share/icons/breeze/status/24/"
      "$out/share/icons/breeze/status/22/"
      "$out/share/icons/breeze/status/16/"
    )
    for path in "''${paths[@]}"; do
      mkdir -p "''$path"
      ln -s \
        "$out/share/icons/breeze/status/64/caffeine-cup-full.svg" \
        "''${path}/caffeine-cup-full.svg"
      ln -s \
        "$out/share/icons/breeze/status/64/caffeine-cup-empty.svg" \
        "''${path}/caffeine-cup-empty.svg"
    done

    paths=(
      "$out/share/icons/breeze-dark/status/48/"
      "$out/share/icons/breeze-dark/status/32/"
      "$out/share/icons/breeze-dark/status/24/"
      "$out/share/icons/breeze-dark/status/22/"
      "$out/share/icons/breeze-dark/status/16/"
    )
    for path in "''${paths[@]}"; do
      mkdir -p "''$path"
      ln -s \
        "$out/share/icons/breeze-dark/status/64/caffeine-cup-full.svg" \
        "''${path}/caffeine-cup-full.svg"
      ln -s \
        "$out/share/icons/breeze-dark/status/64/caffeine-cup-empty.svg" \
        "''${path}/caffeine-cup-empty.svg"
    done
  '';
in
  symlinkJoin {
    name = "caffeine-ng";
    paths = [caffeine-ng iconPkg];
  }
