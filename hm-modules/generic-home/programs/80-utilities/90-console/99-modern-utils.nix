# some "modern" utils
{
  pkgs,
  pkgsUnstable,
  ...
}: {
  # https://github.com/ibraheemdev/modern-unix

  home.packages = builtins.concatLists [
    (with pkgs; [
      fd
      ripgrep
      ripgrep-all # ripgrep & PDF E-Books & Office documents & etc.
      git

      mprocs

      # nixpkgs-unstable 의 delta 가 빌드에러가 있어서 stable 버전 사용. <2024-08-18>
      delta # replace diff
    ])

    (with pkgsUnstable; [
      hexyl # replace od
      procs # replace ps
      # rm-improved

      viddy # replace watch

      # renamer
      massren

      # sed for json/yaml
      yq
      du-dust # dust(du)
      gping # gping(ping)
      doggo # doqqg(dig)

      just # make alike
    ])
    [
      # (pkgs.writeScriptBin "duf" ''
      #   #!{pkgs.dash}/bin/dash
      #   ${pkgsUnstable.duf}/bin/duf -theme ansi "$@"
      # '')
    ]
  ];
}
