/*
  NOTE: limine(bootloader) can not handle initrd secrets in NixOS 25.05

  ```
  Traceback (most recent call last):
    File "/nix/store/girlvs0qr3v5v42rhjr1znr7568rc23k-limine-install.py", line 460, in <module>
      main()
    File "/nix/store/girlvs0qr3v5v42rhjr1znr7568rc23k-limine-install.py", line 328, in main
      config_file += generate_config_entry(profile, gen, isFirst)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/nix/store/girlvs0qr3v5v42rhjr1znr7568rc23k-limine-install.py", line 190, in generate_config_entry
      entry += config_entry(depth, boot_spec, f'Generation {gen}', str(time))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/nix/store/girlvs0qr3v5v42rhjr1znr7568rc23k-limine-install.py", line 151, in config_entry
      initrd_secrets_path = limine_dir + '/kernels/' + os.path.basename(toplevel) + '-secrets'
                                                                        ^^^^^^^^
  NameError: name 'toplevel' is not defined
  Failed to install bootloader
  ```

  - <https://github.com/NixOS/nixpkgs/pull/429081> 에서 고쳐진듯 하다.
*/
{
  pkgs,
  lib,
  ...
}:
{
  boot = {
    # enable lanzaboote after creating keys (`sbctl create-keys`)
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      settings.console-mode = "keep"; # use vendor's firmware's default
    };
    loader.systemd-boot = {
      enable = lib.mkForce false;
      configurationLimit = 50;
    };
    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    kernelParams = [
      "amdgpu.dc=0" # fix amdgpu - flip_done timed out <https://forum.manjaro.org/t/system-freeze-amdgpu-flip-done-timed-out-after-switch-to-kernel-6-12/176608> (Kernel 6.12)

      "zswap.enabled=1"
      "zswap.compressor=lz4"
    ];
  };

  environment.systemPackages = [
    # for secure-boot
    pkgs.sbctl
  ];
}
