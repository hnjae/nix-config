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
    # NOTE: amdvlk has issue with gnome libadwaita shadow rendering <NixOS 24.11>
    amdvlk = {
      enable = true;
    };
    opencl = {
      enable = true;
    };
  };

  nixpkgs.config.rocmSupport = false;
  # environment.variables = {
  #   ROC_ENABLE_PRE_VEGA = "1";
  # };

  # amdgpu.virtual_display=xxxx:xx:xx.x,y
}
