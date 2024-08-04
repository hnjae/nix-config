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

    prev_img=$(
      podman images --format json |
        jq -r '.[] | select(.Names | index("${image}")) | .Id' |
        uniq
    )
    new_img=$(podman pull "${image}" 2>/dev/null)

    if [ "''$prev_img" = "''$new_img" ]; then
      echo "INFO: ${image} is up to date"
      exit 0
    fi

    echo "INFO: detected updates of ${image}"
    systemctl restart "${targetService}"

    echo "INFO: removing previous ${image} (''${prev_img})"
    podman rmi "''$prev_img" 2>/dev/null
  '';
}
