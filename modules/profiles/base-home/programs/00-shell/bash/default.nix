{ pkgs, config, ... }:
{

  # Disable bash integration by default (available when 25.05)
  # home.shell.enableBashIntegration = false;

  programs.bash = {
    enable = false;
    historyFile = "${config.xdg.stateHome}/bash_history";
    # historyIgnroe = [
    #   "ls"
    #   "cd"
    #   "clear"
    #   "exit"
    #   "fg"
    #   "bg"
    # ];
  };
}
