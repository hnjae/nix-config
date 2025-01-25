flakeArgs@{
  inputs,
  self,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
in
{
  flake.nixosModules.base-nixos = {
    imports = [
      ./.
      (importApply ./with-import-apply/users.nix { localFlake = self; })

      self.nixosModules.nix-gc-system-generations
      self.nixosModules.nix-store-gc
      inputs.home-manager.nixosModules.home-manager
      {
        nixpkgs.overlays = [
          flakeArgs.self.overlays.default
        ];
        nixpkgs.config.allowUnfree = true;
      }
      (
        {
          lib,
          config,
          ...
        }:
        {
          # for nix shell nixpkgs#foo
          # run `nix registry list` to list current registry
          nix.registry = {
            nixpkgs-unstable = {
              flake = flakeArgs.inputs.nixpkgs-unstable;
              to = {
                path = "${flakeArgs.inputs.nixpkgs-unstable}";
                type = "path";
              };
            };
            nixpkgs = {
              flake = flakeArgs.inputs.nixpkgs;
              to = {
                path = "${flakeArgs.inputs.nixpkgs}";
                type = "path";
              };
            };
          };

          # to use nix-shell, run `nix repl :l <nixpkgs>`
          nix.channel.enable = true;
          nix.nixPath = lib.lists.optionals config.nix.channel.enable [
            "nixpkgs=${flakeArgs.inputs.nixpkgs}"
            "nixpkgs-unstable=${flakeArgs.inputs.nixpkgs-unstable}"
            # "/nix/var/nix/profiles/per-user/root/channels"
          ];
        }
      )
      (
        { config, ... }:
        let
          cfg = config.base-nixos;
        in
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = false;
            backupFileExtension = "backup";
            sharedModules = [
              flakeArgs.self.homeManagerModules.base-home
            ];
            extraSpecialArgs = { };
            users.hnjae = _: {
              home.stateVersion = "24.05";
              base-home = {
                isDesktop = cfg.role == "desktop";
                isDev = cfg.role == "desktop";
                isHome = true;
              };
              stateful.enable = cfg.role == "desktop";
            };
          };
        }
      )
    ];
  };
}
