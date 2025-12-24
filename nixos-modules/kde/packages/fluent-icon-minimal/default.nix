{
  pkgs ? import <nixpkgs> { },
}:
(pkgs.fluent-icon-theme.overrideAttrs (_: {
  installPhase = ''
    runHook preInstall

    PWD_="$(pwd)"

    sed 's/.*gtk-update-icon-cache.*//g' ./install.sh | \
      bash -s -- \
        --dest $out/share/icons \
        --name Fluent

    echo "rm-icons"
    cd $out/share/icons/Fluent/scalable/apps
  ''
  + builtins.readFile ./rm-icons.sh
  + ''
    cd "$PWD_"

    jdupes --link-soft --recurse $out/share

    for theme in $out/share/icons/*; do
      [ ! -h "$theme" ] && gtk-update-icon-cache $theme
    done

    runHook postInstall
  '';
}))
