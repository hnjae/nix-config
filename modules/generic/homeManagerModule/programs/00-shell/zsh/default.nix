{
  config,
  pkgs,
  pkgsUnstable,
  ...
}: let
  # inherit (config.home) shellAliases;
  # inherit (lib.strings) optionalString;
  concat = builtins.concatStringsSep "\n";
in {
  imports = [
    ./profile.nix
    ./zsh-abbr.nix
  ];

  home.packages = [
    # provides various /nix/store/<hash>/share/zsh/site-functions
    pkgsUnstable.zsh-completions
  ];

  # NOTE: source order:
  # .zshenv, .zprofile, .zlogin(optional?), .zshrc | .zlogout
  # home.sessionVariables 는 .zshenv의 머리에,
  # home.shellAliases 는 .zshrc 말미에 적힘
  # home-manager:
  # localVariables??
  # envExta
  # profileExtra
  # initExtraFirst initExtraBeforeCompInit initExta
  # logoutExtra

  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";

    # NOTE: envExtra being ignored or override for unknown reason <2023-03-26>
    # .zshenv 말미
    # envExtra = "";

    # .zprofle
    # profileExtra = "";

    initExtraBeforeCompInit = ''
      # source "${pkgs.nix-zsh-completions}/share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh"
      fpath=(${pkgs.nix-zsh-completions}/share/zsh/site-functions $fpath)
    '';

    # .zshrc 중간 (after zplugin, history)
    initExtra = concat [
      ''
        # https://github.com/Aloxaf/fzf-tab/issues/477
        zstyle ':fzf-tab:*' default-color ""
        zstyle ':fzf-tab:*' use-fzf-default-opts yes
        # zstyle ':fzf-tab:*' fzf-flags --color=fg+:8
        zstyle ':fzf-tab:*' fzf-flags --color=16

        # fzf-tab should be loaded before zsh-autosuggestions and zsh-fast-syntax-highlighting
        . "${pkgsUnstable.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"


        # history 에서 일치하는 명령 줄 배경색으로 표기
        . "${pkgsUnstable.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

        # syntax highlighting
        . "${pkgsUnstable.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh"

        # alias 에 있는 커맨드와 동일하면 표기
        # zsh-abbr 를 사용하므로 사용하지 말자.
        # . "${pkgsUnstable.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh"

        # run `zhooks` to display functions and array <https://github.com/agkozak/zhooks>
        . "${pkgsUnstable.zsh-zhooks}/share/zsh/zhooks/zhooks.plugin.zsh"
      ''
      # starship, zoxide, skim, direnv, aliases will follow

      ''
        # EDITOR가 vi 이여도, ^A, ^E 같은 emacs 키는 사용할 수 있게 설정
        # https://github.com/simnalamburt/.dotfiles/blob/997d482/.zshrc
        if (( $+commands[vim] )) || (( $+commands[nvim] )); then
          bindkey '^A' beginning-of-line
          bindkey '^E' end-of-line
        fi
      ''
    ];

    history = {
      path = "${config.xdg.stateHome}/zsh_history";
      ignoreDups = true;
      ignorePatterns = [
        # cd
        "cd *"
        "s *"

        # files
        "rm *"
        "sudo rm *"
        "trash *"
        "trash-put *"
        "trash-rm *"
        "trash-empty"
        # "trash-restore"
        # "trash-list"
        "mv"

        # ls & misc
        # "pwd"

        "pfkill"

        #
        "clear"
        "exit"
        "fg"
        "bg"

        # filesystems
        "zfs destroy *"
        "zpool destroy *"
        "btrfs subvolume delete *"
        "sudo zfs destroy *"
        "sudo zpool destroy *"
        "sudo btrfs subvolume delete *"

        # dangerous commands
        "reboot"
        "shutdown"
        "halt"
        "kexec"
        "systemctl reboot"
        "systemctl halt"
        "systemctl poweroff"
        "systemctl kexec"
        "systemctl soft-reboot"
      ];
      ignoreSpace = true;
      extended = true; # save timestamp into the history file
      expireDuplicatesFirst = true;
      ignoreAllDups = true;
      save = 99999;
      size = 99999;
      share = true;
    };
  };
}
