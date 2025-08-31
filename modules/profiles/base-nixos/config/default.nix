flakeArgs@{ importApply, ... }:
{
  imports = [
    ./containers.nix
    ./davfs2.nix
    ./env.nix
    ./firewall.nix
    ./locale.nix
    ./lofree-keyboard-fix.nix
    ./login-defs.nix
    ./polkit.nix
    ./samba.nix
    ./sops.nix
    ./sysctl.nix
    ./systemd.nix
    ./time.nix
    ./tmpfiles.nix
    ./zram.nix
    (importApply ./users.nix flakeArgs)
    (importApply ./nix.nix flakeArgs)
    (importApply ./nixpkgs.nix flakeArgs)
    (importApply ./users-deploy.nix flakeArgs)
    (importApply ./home-manager.nix flakeArgs)
  ];
}
