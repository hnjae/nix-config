{
  pkgsUnstable,
  lib,
  config,
  ...
}: {
  programs.atuin = {
    enable = true;
    package = pkgsUnstable.atuin;
  };

  # use atuin as history manager
  programs.zsh.history = let
    inherit (lib) mkForce;
  in {
    save = mkForce 0;
    size = mkForce 0;
    share = mkForce false;
  };

  programs.bash = with lib; {
    historyFileSize = mkForce 0;
    historySize = mkForce 0;
  };

  stateful.nocowNodes = [
    {
      path = "${config.xdg.dataHome}/atuin";
      mode = "755";
      type = "dir";
    }
  ];

  # home.file."${config.xdg.dataHome}/fish/fish_history" = {
  # };
}
