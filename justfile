alias t := test
alias fmt := format

format:
  nix fmt --no-warn-dirty

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

drybuild-home-desktop-plasma6-unfree-x86_64-linux:
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
      ".#homeConfigurations.desktop-plasma6-unfree-x86_64-linux.activationPackage"

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

test: test-flake drybuild-homes
