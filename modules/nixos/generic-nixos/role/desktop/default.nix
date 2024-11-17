{...}: {
  # config = lib.mkIf (config.generic-nixos.role == "desktop") (lib.mergeAttrsList (builtins.map (
  #     file: ((import file) {
  #       inherit lib pkgs config;
  #     })
  #   ) [
  #     ./configs/documentation.nix
  #     ./configs/flatpak.nix
  #     ./configs/fonts.nix
  #     ./configs/gnupg.nix
  #     ./configs/locate.nix
  #     ./configs/polkit.nix
  #     ./configs/printing.nix
  #     ./configs/resolve.nix
  #     ./configs/upower.nix
  #   ]));
  imports = [
    # ./plasma6.nix
    ./1password.nix
    ./documentation.nix
    ./flatpak.nix
    ./fonts.nix
    ./gnome
    ./gnupg.nix
    ./locate.nix
    ./packages.nix
    ./portal-pipewire.nix
    ./printing.nix
    ./upower.nix
  ];
}
