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
  containerName,
  targetService,
}:
# e.g.) image = "docker.io/lobehub/lobechat:latest"
pkgs.writeShellApplication {
  inherit name;

  runtimeInputs = with pkgs; [
    podman
    jq
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
      podman ps --format json |
        jq -r '.[] | select(.Names | index("${containerName}")) | .ImageID'
    )

    if [ -z "''$prev_img" ]; then
      echo "ERROR: ${containerName} is not running"
      exit 1
    fi

    new_img=''$(podman pull "${image}" 2>/dev/null)

    if [ "''$prev_img" = "''$new_img" ]; then
      echo "INFO: ${containerName}'s image is up to date"
      exit 0
    fi

    echo "INFO: detected updates of ${containerName}"

    echo "INFO: restarting service ${targetService}"
    systemctl restart "${targetService}"

    #  다른 컨테이너가 해당 이미지를 사용하는지 확인하고 지우기.
    other_cons=''$(
      podman ps --format json |
        jq -r ".[] | select(.ImageID | index(\"''${prev_img}\")) | .Id"
    )

    prev_img_c=''$(echo "''$prev_img" | cut -c -12)
    if [ -n "''$other_cons" ]; then
      echo "INFO: previous image of ${containerName} (''${prev_img_c}) is being used by other containers"
      exit 0
    fi

    echo "INFO: removing previous image of ${containerName} (''${prev_img_c})"
    podman rmi "''$prev_img" 2>/dev/null
  '';
}
