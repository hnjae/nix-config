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
    ./documentation.nix
    ./flatpak.nix
    ./fonts.nix
    ./gnupg.nix
    ./locate.nix
    # ./plasma6.nix
    ./gnome.nix
    ./portal-pipewire.nix
    ./printing.nix
    ./upower.nix
  ];
}
