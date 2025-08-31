{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/amd/default.nix
    # 하는 것 <2024-08-02>
    # xserver videodriver 를 modesettings 으로, initrd 에서 amdgpu 활성화

    inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = false;
    # extraPackages = with pkgs; [ ];
  };

  environment.defaultPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd
    # rocmPackages.rocm-smi
    # rocmPackages.rocminfo

    # infos
    clinfo # opencl
    glxinfo
    vulkan-tools
    libva-utils
  ];

  hardware.amdgpu = {
    initrd.enable = false;
    amdvlk.enable = true;
    opencl.enable = false;
  };

  nixpkgs.config.rocmSupport = false;
}
