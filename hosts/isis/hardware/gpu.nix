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

  environment.defaultPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd

    rocmPackages.rocminfo
    rocmPackages.rocm-smi

    # infos
    clinfo # opencl
    glxinfo
    vulkan-tools
    libva-utils
  ];

  # NOTE: 하나의 드라이버만 쓰겠다면 패키지 목록에 추가 안해도 상관 없는데, 여러개의 드라이버를 적재적소에 쓰기 위해서는 **모두** 추가해야 한다. <2025-01-05>
  environment.systemPackages = with pkgs; [
    amdvlk # /run/current-system/sw/share/vulkan/icd.d/amd_icd64.json
    mesa.drivers # /run/current-system/sw/share/vulkan/icd.d/radeon_icd.x86_64.json
  ];

  # https://wiki.archlinux.org/title/Vulkan
  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
  };

  # 표준 경로에 링크하여, 프로그램에서 쉽게 참조할 수 있도록 한다.
  systemd.tmpfiles.rules = [
    "L /usr/share/vulkan - - - - /run/current-system/sw/share/vulkan"
  ];

  hardware.amdgpu = {
    initrd.enable = false;
    # NOTE: amdvlk has issue with gnome libadwaita shadow rendering <NixOS 24.11>
    # default vulkan implementation (mesa) does not support realesrgann in 7840U
    amdvlk = {
      enable = false;
    };
    opencl = {
      enable = true;
    };
  };

  nixpkgs.config.rocmSupport = true;

  programs.nix-ld.libraries = with pkgs; [
    vulkan-loader
  ];

  home-manager.sharedModules = [
    {
      # use amdvlk only in interactive shell
      programs.zsh.initExtra = ''
        export DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1="1"
        export VK_DRIVER_FILES="/run/current-system/sw/share/vulkan/icd.d/amd_icd64.json"
      '';
    }
  ];
}
