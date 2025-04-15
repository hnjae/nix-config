_: {
  imports = [
    ./50-editors
    ./50-pdf

    ./calibre.nix
    ./latex.nix
    ./libreoffice.nix
    ./logseq.nix
    ./obsidian
    ./onlyoffice.nix
    ./typst.nix
    ./zotero.nix
  ];

  services.flatpak.packages = [
    "com.github.johnfactotum.Foliate"
  ];
}
