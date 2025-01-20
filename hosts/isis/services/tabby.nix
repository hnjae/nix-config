# WIP
# https://github.com/TabbyML/tabby
{config, ...}: let
  serviceName = "tabby";
in {
  virtualisation.oci-containers.containers."${serviceName}" = {
    image = "ghcr.io/tabbyml/tabby-rocm";
    autoStart = true;
    environment = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.2";
    };
    volumes = [
      "/usr/local/share/tabby:/data" # zfs datasets
    ];
    ports = [
      "8080:8080"
    ];
    extraOptions = [
      # https://tabby.tabbyml.com/blog/2024/01/24/running-tabby-locally-with-rocm/
      "--memory=8G"
      "--cpus=8"
      "--device=/dev/kfd"
      "--device=/dev/dri"
      "--security-opt"
      "seccomp=unconfined"
      "--group-add"
      "video"
    ];
    cmd = [
      "serve"
      "--device"
      "rocm"
      "--model"
      "Qwen2.5-Coder-3B"
      "--chat-model"
      "Qwen2.5-Coder-0.5B-Instruct"
    ];
  };
  #
  # home-manager.sharedModules = [
  #   {
  #     home.shellAliases.tabby = "sudo podman exec -it tabby tabby";
  #   }
  # ];
}
