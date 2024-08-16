{
  pkgsUnstable,
  lib,
  config,
  ...
}: {
  programs.atuin = {
    enable = true;
    package = pkgsUnstable.atuin;
    flags = [
      # "--disable-up-arrow"
      # "--disable-ctrl-r"
    ];
    # settings = lib.mkMerge [
    #   {
    #     # UI
    #     prefers_reduced_motion = true;
    #     style = "compact";
    #     invert = true;
    #     inline_height = 24;
    #     show_preview = false;
    #   }
    #   {
    #     # 동작
    #     search_mode = "fuzzy";
    #     filter_mode_shell_up_key_binding = "directory";
    #     enter_accept = false;
    #   }
    #   {
    #     # 동기화
    #     auto_sync = false;
    #     update_check = false;
    #   }
    #   {
    #     secrets_filter = false;
    #   }
    #   {
    #     history_filter = [
    #       #   "^OPENAI_API_KEY=.*$"
    #       #   "^atuin history prune[^-]*$" # dry-run first!
    #       #   # rsync
    #       #   "^rcp [^(-n)]*"
    #       #   "^rsync [^(-n)]*"
    #       #   # cd
    #       #   # "^s .*"
    #       #   # "^cd .*"
    #       #   # files
    #       #   "^rm .*"
    #       #   "^rm -rf"
    #       #   "^trash .*"
    #       #   "^trash-put"
    #       #   #
    #       #   "fg"
    #       #   "bg"
    #       #   #
    #       #   "clear"
    #       # dangerous commands
    #       "^reboot"
    #       "^shutdown"
    #       "^halt"
    #       "^kexec"
    #       "^systemctl reboot"
    #       "^systemctl halt"
    #       "^systemctl poweroff"
    #       "^systemctl kexec"
    #       "^systemctl soft-reboot"
    #       # "^.*\\.[mp4|mkv|avi] .*"
    #       #   "^secret-cmd"
    #       #   "^innocuous-cmd .*--secret=.+"
    #     ];
    #     store_failed = false;
    #   }
    #   {
    #     stats.common_prefix = ["sudo"];
    #     stats.common_subcommands = [
    #       # package manager
    #       "apt"
    #       "dnf"
    #       #
    #       "docker"
    #       "podman"
    #       "kubectl"
    #       #
    #       "systemctl"
    #       "nmcli"
    #       "ip"
    #       "git"
    #       #
    #       "npm"
    #       "pnpm"
    #       "yarn"
    #       #
    #       "go"
    #       "nix"
    #       "cargo"
    #       #
    #       "tmux"
    #       #
    #       # "composer"
    #       # "pecl"
    #       # "port"
    #     ];
    #   }
    # ];
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
