/*
NOTE: <NixOS 24.05>
  The `oci-containers` in nixpkgs are declared to run images with the `--rm`
  flag, meaning they are disposable containers.
  This means that restarting the service will create a new container that uses
  a new image downloaded.
*/
{
  pkgs,
  name,
  image,
  targetService,
}:
# e.g.) image = "docker.io/lobehub/lobechat:latest"
pkgs.writeShellApplication {
  inherit name;

  runtimeInputs = with pkgs; [
    podman
    jq
    coreutils
    systemd
  ];

  text = ''
    set -e

    if [ "''${UID:-''$(id -u)}" != "0" ]; then
      echo "ERROR: not running as root"
      exit 1
    fi

    if ! systemctl is-active --quiet "${targetService}"; then
      echo "ERROR: ${targetService} is not active"
      exit 1
    fi

    prev_img=''$(
      podman images --format json |
        jq -r '.[] | select(.Names | index("${image}")) | .Id' |
        uniq
    )
    new_img=''$(podman pull "${image}" 2>/dev/null)

    if [ "''$prev_img" = "''$new_img" ]; then
      echo "INFO: ${image} is up to date"
      exit 0
    fi

    echo "INFO: detected updates of ${image}"

    echo "INFO: restarting service ${targetService}"
    systemctl restart "${targetService}"

    echo "INFO: removing previous image of ${image} (''${prev_img})"
    podman rmi "''$prev_img" 2>/dev/null
  '';
}
