{...}: let
  mc = ''
    mc() {
      dir="$*"
      [ ! -z "$dir" ] && [ -n "$dir" ] && mkdir -p "$dir" && cd "$dir"
    }
  '';
in {
  programs.zsh.initExtra = mc;
  programs.bash.initExtra = mc;
  programs.fish.functions.mc = {
    body = ''
      set dir "$argv"
      [ ! -z "$dir" ] && [ -n "$dir" ] && mkdir -p "$dir" && cd "$dir"
    '';
    description = "make directory and cd";
  };
}
