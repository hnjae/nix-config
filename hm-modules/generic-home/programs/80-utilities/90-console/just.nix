{pkgsUnstable, ...}: {
  home.packages = builtins.concatLists [
    (with pkgsUnstable; [
      just # make alike
    ])
  ];

  home.shellAliases = {j = "just";};
}
