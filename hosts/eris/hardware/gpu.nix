{ pkgs, ... }:
{
  environment.defaultPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd

    # infos
    clinfo # opencl
    mesa-demos # glxinfo
    vulkan-tools
    libva-utils
  ];

  hardware.amdgpu = {
    initrd.enable = false;
    opencl.enable = false;
  };
}
