{
  inputs,
  pkgs,
  ...
}:
{
  boot.kernelModules = [ "kvm-amd" ];

  imports = [
    # ./amd-pstate/active
    # ./amd-pstate/guided.nix
    ./amd-pstate/passive.nix

    # includes `updateMicrocoder`
    inputs.nixos-hardware.nixosModules.common-cpu-amd
  ];

  # CPU
  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.system-features = [
    "kvm"
    "big-parallel"
    "nixos-test"
    "benchmark"
    "gccarch-x86-64-v2"
    "gccarch-x86-64-v3"
    "gccarch-x86-64-v4" # amd zen4 (7840U)
    "gccarch-znver1"
    "gccarch-znver2"
    "gccarch-znver3"
    "gccarch-znver4" # amd zen4 (7840U)
  ];

  # 8c16t cpu
  nix.settings.max-jobs = 8;
  nix.settings.cores = 8;

  boot.kernelParams = [
    # "nosmt"
  ];
}
