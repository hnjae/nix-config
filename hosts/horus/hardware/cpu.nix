{ self, inputs, ... }:
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

  nixpkgs.hostPlatform = inputs.flake-utils.lib.system.x86_64-linux;

  # 8c16t cpu
  nix.settings = {
    max-jobs = 8;
    cores = 8;
    system-features = self.constants.hosts.horus.buildMachine.supportedFeatures;
  };
}
