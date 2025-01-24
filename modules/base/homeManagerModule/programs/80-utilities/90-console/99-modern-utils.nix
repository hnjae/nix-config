# some "modern" utils
{
  pkgs,
  pkgsUnstable,
  ...
}:
{
  # https://github.com/ibraheemdev/modern-unix

  home.packages = builtins.concatLists [
    (with pkgs; [
      fd
      ripgrep
      ripgrep-all # ripgrep & PDF E-Books & Office documents & etc.
      sd # modern sed
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
      vimv-rs # cyclic-renaming 지원, 엣지 케이스 대응 잘함.
      # massren # 설정 파일이 존재하며, 심지어 plain text 가 아니라 sqlite 파일

      # sed for json/yaml
      yq
      du-dust # dust(du)
      gping # gping(ping)
      doggo # doqqg(dig)

      just
    ])
    [
      # (pkgs.writeScriptBin "duf" ''
      #   #!{pkgs.dash}/bin/dash
      #   ${pkgsUnstable.duf}/bin/duf -theme ansi "$@"
      # '')
    ]
  ];
}
