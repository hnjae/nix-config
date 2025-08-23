/*
  NOTE:
    * <https://www.freedesktop.org/software/systemd/man/latest/bootup.html>
    * <https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167/6>
*/
{
  config,
  self,
  pkgs,
  ...
}:
{
  boot.initrd = {
    compressor = "cat";
    availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sr_mod"

      "r8169" # network drive. run `lsmod` to list loaded kernel modules
    ];
    systemd = {
      enable = true;

      users.root.shell = "/bin/systemd-tty-ask-password-agent";

      initrdBin = with pkgs; [
        zfs
      ];

      services.rollback = {
        description = "Restore ZFS root dataset to empty state";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          "zfs-import.target"
        ];
        before = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r -- 'eris/local/rootfs@blank'
        '';
      };

      network = {
        enable = true;
        inherit (config.systemd.network) networks netdevs;
      };
    };

    network.ssh = {
      enable = true;
      port = 22;
      authorizedKeys = [
        self.shared.keys.ssh.home
      ];
      hostKeys = [
        config.sops.secrets.ssh-host-ed25519-key.path
      ];
    };
  };
}
