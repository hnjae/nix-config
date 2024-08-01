{
  lib,
  pkgs,
  ...
}: {
  imports = [./rsync.nix ./ls.nix];

  # zsh, bash, fish 공통사용
  home.shellAliases =
    {
      cp = "cp -i --preserve=all --reflink=auto --one-file-system";
      mv = "mv -i";
      #
      fmime = "file --mime-type --brief --";
      xmime = "xdg-mime query filetype";
      nfd2nfc = "convmv -r -f utf8 -t utf8 --nfc .";
      nfd2nfc-run = "convmv -r -f utf8 -t utf8 --nfc --notest .";
      colorpattern = "curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/e50a28ec54188d2413518788de6c6367ffcea4f7/print256colours.sh | bash";
    }
    // (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      sys = "systemctl";
      sysu = "systemctl --user";

      # home.packages 에 bashInteractive 추가하는 걸로 안됨. <NixOS 23.11>
      bash = "${pkgs.bashInteractive}/bin/bash";
    });
}
