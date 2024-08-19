{...}: let
  mcFuncPosix = ''
    mc() {
      dir="$*"
      [ ! -z "$dir" ] && [ -n "$dir" ] && mkdir -p "$dir" && cd "$dir"
    }
  '';
in {
  programs.zsh.initExtra = mcFuncPosix;
  programs.bash.initExtra = mcFuncPosix;
  programs.fish.functions.mc = {
    body = ''
      set dir "$argv"
      [ ! -z "$dir" ] && [ -n "$dir" ] && mkdir -p "$dir" && cd "$dir"
    '';
    description = "make directory and cd";
  };
}
