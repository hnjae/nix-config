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
    ])

    (with pkgsUnstable; [
      hexyl # replace od
      procs # replace ps
      # rm-improved

      delta # replace diff
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
