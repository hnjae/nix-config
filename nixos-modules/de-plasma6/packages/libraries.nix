{pkgs, ...}: {
  environment.systemPackages = with pkgs.kdePackages; [
    # image supports in dolphin, ...
    qtimageformats # webp, ...
    kimageformats # avif, jxl, heif, ...

    # qtpbfimageplugin
    # kdegraphics-mobipocket
    # kdegraphics-thumbnailers
    # ffmpegthumbs
    # kio-extras

    # syntax-highlighting
    # syndicatoin
    # sonnet
    # solid
  ];
}
