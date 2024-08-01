{pkgs, ...}: {
  home.packages = [
    # fm
    (pkgs.ranger.override {
      w3m = null;
      imagePreviewSupport = false;
      neoVimSupport = false;
    })
  ];
  home.shellAliases = {ra = "ranger";};
}
