{
  config,
  lib,
  inputs,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
  # TODO: make user-abbreviations using nix <2024-12-27>
in {
  imports = [
    # ./gitui
  ];

  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      git-open
      git-crypt
      git-lfs

      gitu
    ];

    services.flatpak.packages = lib.mkIf (genericHomeCfg.isDesktop && genericHomeCfg.installTestApps) [
      # opensource git client
      # "com.jetpackduba.Gitnuro" # gpl3, jvm
      # "com.github.Murmele.Gittyup" # mit
      # "org.kde.kommit" # gpl3
      # "de.philippun1.turtle" # gpl3, libadwaita
      # "org.gnome.gitg" # gpl2
    ];

    # bindings https://github.com/wfxr/forgit 참고
    home.shellAliases = {
      gu = "gitu";
    };

    programs.zsh.localVariables = {
      forgit_add = "ga"; # defaults
      forgit_branch_delete = "gbD";
      forgit_blame = "gbl"; # defaults
      forgit_cherry_pick = "gcp"; # defaults
      forgit_diff = "gdz";
      forgit_log = "glz";
      forgit_rebase = "grb"; # defaults
      forgit_revert_commit = "grev";
      forgit_reset_head = "grhd";
      forgit_checkout_file = "grs"; # git-restore
      forgit_stash_show = "gshs";
      forgit_stash_push = "gshP";
      forgit_checkout_branch = "gsw"; # git-switch
      forgit_checkout_tag = "gswt";
      forgit_checkout_commit = "gswco";
      forgit_reflog = "greflog";
      forgit_clean = "gclean";
      forgit_ignore = "gignoredgenerate";
      forgit_fixup = "gfixup";
    };

    programs.zsh.initExtra = ''
      git-branch-delete-merged () {
        # TODO: fix this <2024-12-31>
        # this does not deletes remote branch
        # https://gist.github.com/schacon/942899
        # https://gist.github.com/ryanc414/f7686d2c97808b41ed8518a5840e2d78
        git branch --no-color --merged | command grep -vE "^(\+|\*|\s*(master|main|develop|dev)\s*$)" | command xargs -n 1 git branch -d
      }

      git-tag-list () {
        git tag --sort=-v:refname -n -l "''${1}*"
      }

      git-root () {
        cd "$(git rev-parse --show-toplevel || echo .)"
      }

      git-wip () {
        git add -A
        git rm $(git ls-files --deleted) 2> /dev/null
        git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"
      }

      git-unwip () {
        git log -n 1 | grep -q -c "--wip--" && git reset 'HEAD~1'
      }

      git-todo () {
        if [ -z "$*" ]; then
          echo "Usage: git-todo <msg>"
          return
        fi

        git commit --allow-empty --no-verify --no-gpg-sign -m "--wip-- TODO: $*"
      };

      . "${pkgsUnstable.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh"
    '';
    xdg.configFile."zsh-abbr/user-abbreviations" = {
      source = ./resources/user-abbreviations;
    };
  };
}
