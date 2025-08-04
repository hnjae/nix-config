{ config, lib, ... }:
let
  inherit (config.home) homeDirectory username;
in
{
  systemd.user.tmpfiles.rules = lib.flatten [
    # "v ${homeDirectory}/.cache 755 ${username} users 7d" # NOTE: 이거 nix update 에서 각종 이슈 낳음 <2024-12-10>
    "R ${homeDirectory}/.mypy_cache - - - -"
    "R ${homeDirectory}/.vim - - - -"
    "R ${homeDirectory}/.viminfo - - - -"
    "R ${homeDirectory}/.python_history - - - -" # python 3.13 부터는 PYTHON_HISTORY 로 위치를 옮길수 있다.
  ];
}
