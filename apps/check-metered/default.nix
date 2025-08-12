{
  pkgs ? import <nixpkgs> { },
}:
(pkgs.writeScript "check-metered" (
  pkgs.lib.concatLines [
    ''
      #!${pkgs.nushell}/bin/nu

      $env.PATH = [
        '${pkgs.networkmanager}/bin'
      ]
    ''
    (builtins.readFile ./check-metered.nu)
  ]
))
