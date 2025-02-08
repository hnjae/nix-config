{ pkgs, ... }:
{
  # to preview files
  # https://github.com/ranger/ranger/blob/master/ranger/data/scope.sh
  home.packages = with pkgs; [
    exiftool
    mediainfo
    (pkgs.runCommandLocal "transmission-show" { } ''
      mkdir -p "$out/bin"
      ln -s "${pkgs.libtransmission_4}/bin/transmission-show" "$out/bin/transmission-show"
    '')
  ];
  python = {
    enable = true; # my config file uses python script
    pythonPackages = [
      # "rarfile"
      # "tabulate"
      # "python-magic"
    ];
  };

  programs.pistol = {
    enable = true;
    associations = builtins.concatLists [
      [
        {
          mime = "inode/directory";
          command = "eza --all --links --time-style long-iso --color=always --icons=always --git --mounts --extended --group-directories-first -- %pistol-filename%";
        }
      ]
      (map
        (mime: {
          inherit mime;
          command = "bat --style=plain --color=always --paging=never --italic-text=always --wrap=character -- %pistol-filename%";
        })
        [
          "text/*"
          "application/json"
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
          command = "exiftool -- %pistol-filename%";
        })
        [
          "image/*"
          "application/pdf"
          "application/vnd.oasis.opendocument.*"
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
          mime = "application/x-bittorrent";
          command = "transmission-show -- %pistol-filename%";
        }
        {
          mime = "application/octet-stream";
          command = "hexyl --block-size=4096 --length=2block --border=none -- %pistol-filename%";
        }
      ]
    ];
  };
}
