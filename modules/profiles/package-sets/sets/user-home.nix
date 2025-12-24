{
  localFlake,
  inputs,
  lib,
  ...
}:
pkgs:
(
  let
    inherit (pkgs.stdenv) hostPlatform;
  in
  lib.flatten [
    (lib.lists.optional (inputs ? py-utils) inputs.py-utils.packages.${hostPlatform.system}.default)

    localFlake.packages.${hostPlatform.system}.wincompat-rename
  ]
)
