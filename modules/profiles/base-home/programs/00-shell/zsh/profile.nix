{
  config,
  lib,
  ...
}:
{
  programs.zsh = {
    # .zprofle
    profileExtra = lib.mkOrder 1 ''
      [ -n "$__PROFILE_SOURCED" ] && return
      __PROFILE_SOURCED=1
    '';

    initContent = lib.mkOrder 1 ''
      [ -z "$__PROFILE_SOURCED" ] &&
        [ -f "$HOME/${config.programs.zsh.dotDir}/.zprofile" ] &&
        . "$HOME/${config.programs.zsh.dotDir}/.zprofile"
    '';
  };
}
