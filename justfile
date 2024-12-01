alias t := test
alias fmt := format

format:
  nix fmt --no-warn-dirty

flake-update-except-unstable:
  nix flake lock \
    --update-input nixpkgs \
    --update-input flake-parts \
    --update-input flake-utils \
    --update-input home-manager \
    --update-input plasma-manager \
    --update-input impermanence \
    --update-input rust-overlay \
    --update-input nixpkgs-mozilla \
    --update-input nixvim \
    --update-input nix-index-database \
    --update-input base16-schemes \
    --update-input base24-konsole \
    --update-input base24-kdeplasma \
    --update-input nix-flatpak \
    --update-input nix-web-app \
    --update-input cgitc

open-status:
  xdg-open "https://status.nixos.org/"

test-flake:
  #!/bin/sh
  set -e

  NIXPKGS_ALLOW_UNFREE=1
  nix flake archive --no-warn-dirty
  nix flake check \
    --no-warn-dirty \
    --all-systems \
    --impure # to check unfree packages

drybuild-homes-wip:
  #!/bin/sh

  nix eval \
    --no-warn-dirty \
    --json \
    ".#homeConfigurations" \
    --apply builtins.attrNames |
    jq '.[]' |
    parallel --jobs {{ num_cpus() }} \
    "echo '{}' && nix build \
      --dry-run \
      --no-warn-dirty \
      --no-print-missing \
      --option keep-env-derivations true \
      --option pure-eval true \
      --option show-trace false \
      --quiet \
      --json \
      '.#homeConfigurations.{}.activationPackage' 2> >(sed '/^[[:space:]]*\/nix\/store\//d')"

drybuild-homes:
  #!/bin/sh

  for home in $(
    nix eval \
      --no-warn-dirty \
      --json \
      ".#homeConfigurations" \
      --apply builtins.attrNames |
      jq '.[]'
  ); do
    target=".#homeConfigurations.${home}.activationPackage"
    echo "Dry-building ${target}"

    # nix eval \
    #   --raw \
    #   --no-warn-dirty \
    #   --option eval-cache true \
    #   --quiet \
    #   "${target}"

    nix build \
      --dry-run \
      --no-warn-dirty \
      --no-print-missing \
      --option keep-env-derivations true \
      --option pure-eval true \
      --option show-trace false \
      --quiet \
      --json \
      --builders "" \
      "${target}"

    echo ""
  done

drybuild-nixos-desktop:
  nix build \
    --dry-run \
    --no-warn-dirty \
    --option eval-cache false \
    --no-print-missing \
    --quiet \
    --json \
    --builders "" \
    ".#nixosConfigurations.dekstop.config.system.build.toplevel"

drybuild-nixos-desktop-plasma6:
  nix build \
    --dry-run \
    --no-warn-dirty \
    --option eval-cache false \
    --no-print-missing \
    --quiet \
    --json \
    --builders "" \
    ".#nixosConfigurations.dekstop-plasma6-unfree.config.system.build.toplevel"

# slower than nix flake check
drybuild-nixoses:
  #!/bin/sh
  set -e

  for os in $(
    nix flake show --json 2>/dev/null |
      jq '.nixosConfigurations | to_entries[] | .key' |
      sed 's/"//g'
  ); do
    target=".#nixosConfigurations.${os}.config.system.build.toplevel"
    echo "Dry building ${target}"

    nix build \
      --dry-run \
      --no-warn-dirty \
      --option eval-cache false \
      --no-print-missing \
      --quiet \
      --json \
      --builders "" \
      "${target}"

    echo ""
  done

build-iso:
  nix build .#nixosConfigurations.iso.config.system.build.isoImage

test: test-flake drybuild-homes
