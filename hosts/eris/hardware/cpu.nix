# CPU: AMD 5650GE (Zen 3) / 6C12T
{
  config,
  ...
}:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.kernelModules = [ "kvm-amd" ];

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
  programs.ryzen-monitor-ng.enable = true;

  ############################
  # AMD CPU Power Management #
  ############################
  # NOTE: passive uses less power (Kernel 6.18)
  boot.kernelParams = [ "amd_pstate=passive" ];

  # Get available governor: cpupower frequency-info
  powerManagement.cpuFreqGovernor = "schedutil";
}
