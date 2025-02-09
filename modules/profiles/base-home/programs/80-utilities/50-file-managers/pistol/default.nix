{ pkgs, ... }:
let
  printMime = pkgs.writeScript "print-mime" ''
    #!${pkgs.dash}/bin/dash

    file="$1"
    [ -h "$file" ] && file="$(readlink -f -- "$file")"

    fmime="$(${pkgs.file}/bin/file --mime-type --brief -- "$file")"
    xmime="$(${pkgs.xdg-utils}/bin/xdg-mime query filetype "$file")"

    echo "xdg-mime: $xmime | file: $fmime"
    ${pkgs.file}/bin/file -b -- "$file"
    echo "--------------------"
  '';
in
{
  # to preview files
  # https://github.com/ranger/ranger/blob/master/ranger/data/scope.sh
  home.packages = with pkgs; [
    exiftool
    mediainfo
  ];

  # NOTE: xlsx2csv too slow for file preview
  programs.pistol = {
    enable = true;
    associations = builtins.concatLists [
      [
        {
          mime = "inode/directory";
          command = "eza --all --links --time-style long-iso --color=always --icons=always --git --mounts --extended --group-directories-first -- %pistol-filename%";
        }
        {
          mime = "inode/x-empty";
          command = "${pkgs.dash}/bin/dash -c 'echo inode/x-empty'";
        }
      ]
      (map
        (mime: {
          inherit mime;
          command = "bat --style=plain --color=always --paging=never --italic-text=always --wrap=character -- %pistol-filename%";
        })
        [
          "text/*"
          "application/javascript"
        ]
      )
      (map
        (mime: {
          inherit mime;
          command = "mediainfo -- %pistol-filename%";
        })
        [
          "video/*"
          "audio/*"
        ]
      )
      (map
        (mime: {
          inherit mime;
          command = "${pkgs.odt2txt}/bin/odt2txt %pistol-filename%";
        })
        [
          "application/vnd.oasis.opendocument.text"
          "application/vnd.oasis.opendocument.spreadsheet"
          "application/vnd.oasis.opendocument.presentation"
        ]
      )
      (map
        (mime: {
          inherit mime;
          command = "${import ./archive-previewer { inherit pkgs; }}/bin/archive-previewer %pistol-filename%";
        })
        [
          "application/x-rar"
          "application/zip"
        ]
      )
      [
        {
          mime = "application/json";
          command = "jq --color-output . -- %pistol-filename%";
        }
        {
          mime = "application/pdf";
          command =
            let
              p = pkgs.writeScript "p" ''
                #!${pkgs.dash}/bin/dash

                ${pkgs.exiftool}/bin/exiftool -- "$1"
                echo "--------------------"
                ${pkgs.mupdf-headless}/bin/mutool draw -F txt -i -- "$1" 1-5
              '';
            in
            "${p} %pistol-filename%";
        }
      ]

      (map
        (mime: {
          inherit mime;
          command =
            let
              p = pkgs.writeScript "p" ''
                #!${pkgs.dash}/bin/dash

                ${printMime} "$1"
                ${pkgs.binutils}/bin/readelf -WCa "$1"
              '';
            in
            "${p} %pistol-filename%";
        })
        [
          "application/x-executable"
          "application/x-pie-executable"
          "application/x-sharedlib"
        ]
      )

      (map
        (fpath: {
          inherit fpath;
          command = "${pkgs.atool}/bin/atool --list --  %pistol-filename%";
        })
        [
          ".*\.tar$"
          ".*\.tar\.gz$"
          ".*\.tgz$"
          ".*\.tar\.bz$"
          ".*\.tbz$"
          ".*\.tar\.bz2$"
          ".*\.tbz2$"
          ".*\.tar\.bz3$"
          ".*\.tbz3$"
          ".*\.tar\.lrz$"
          ".*\.tlrz$"
          ".*\.tar\.lzmar$"
          ".*\.tlr$"
          ".*\.tar\.Z$"
          ".*\.taz$"
          ".*\.tar\.lzo$"
          ".*\.tzo$"
          ".*\.tar\.xz$"
          ".*\.txz$"
          ".*\.tar\.zst$"
          ".*\.tzst$"
          ".*\.tar\.lz4$"
          ".*\.tar\.lz$"
        ]
      )
      [
        {
          mime = "application/x-rpm";
          command = "${pkgs.rpm}/bin/rpm -qip -sl %pistol-filename%";
        }
        {
          mime = "application/vnd.debian.binary-package";
          command = "${pkgs.dpkg}/bin/dpkg -I -- %pistol-filename%";
        }
        {
          mime = "application/x-iso9660-image";
          command = "${pkgs.cdrtools}/bin/isoinfo -d -i %pistol-filename%";
        }
        {
          mime = "application/x-qemu-disk";
          command = "${pkgs.qemu-utils}/bin/qemu-img info -- %pistol-filename%";
        }
        {
          mime = "application/x-bittorrent";
          command = "${pkgs.libtransmission_4}}/bin/transmission-show -- %pistol-filename%";
        }
      ]
      [
        {
          mime = "image/*";
          command = "exiftool -- %pistol-filename%";
        }
      ]
      # fallback
      (map
        (mime: {
          inherit mime;
          command =
            let
              p = pkgs.writeScript "p" ''
                #!${pkgs.dash}/bin/dash

                ${printMime} "$1"
                ${pkgs.hexyl}/bin/hexyl --block-size=4096 --length=2block --border=none -- "$1"
              '';
            in
            "${p} %pistol-filename%";
        })
        [
          "application/octet-stream"
          "application/*"
        ]
      )
    ];
  };
}
