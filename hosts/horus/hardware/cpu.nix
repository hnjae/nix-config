{ inputs, ... }:
{
  imports = [
    # includes `updateMicrocoder`
    inputs.nixos-hardware.nixosModules.common-cpu-amd
  ];
  boot.kernelModules = [ "kvm-amd" ];
  # CPU
  boot.kernelParams = [
    "amd_pstate=passive"
  ];
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # 8c16t cpu
  nixpkgs.hostPlatform = inputs.flake-utils.lib.system.x86_64-linux;

  nix.settings = {
    max-jobs = 4;
    cores = 4;
    system-features = [
      "kvm"
      "big-parallel"
      "nixos-test"
      "benchmark"
      "gccarch-x86-64-v2"
      "gccarch-x86-64-v3"
      "gccarch-znver1" # amd 2700 8C16T
    ];
  };
}
