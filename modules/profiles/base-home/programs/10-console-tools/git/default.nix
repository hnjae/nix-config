{
  config,
  lib,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
  gitAliases =
    let
      lFormat = lib.concatStringsSep "␟" [
        "%C(auto)%h"
        "%s"
        "%C(blue)%aI"
        "%C(green)%an"
        "%C(auto)%d"
      ];
      gFormat = lib.concatStringsSep " " [
        "%C(auto)%h"
        "%C(auto)%d"
        "%s"
        "%C(blue)%aI"
        "%C(green)<%an>"
      ];
    in
    {
      "g" = "git";

      ############################################################################
      # 파일 관련
      ############################################################################
      # ga: git-add
      # ga (forgit)        interactive `git add` selector
      "gaa" = "git add --all";
      "gapa" = "git add --patch";
      "gau" = "git add --update";
      "gav" = "git add --verbose";

      # git-rm
      "grm" = "git rm";
      "grmc" = "git rm --cached";

      # grst: git-restore
      # grs: forgit: git-restore
      "grsts" = "git restore --source";
      "grstt" = "git restore --staged";

      ############################################################################
      # log, stat, diff
      ############################################################################
      # git-log
      # glz interactive `git log` viewer (forgit)
      "gl" = "git log --oneline --decorate -19";
      "gll" = "git log --oneline --decorate";

      "gld" = ("git log --color=always --pretty='${lFormat}' -19 | column --table --separator '␟'");
      "gldd" = ("git log --color=always --pretty='${lFormat}' | column --table --separator '␟'");

      "glg" = "git log --oneline --decorate --graph -19";
      "glgg" = "git log --oneline --decorate --graph";

      "glgf" = "git log --graph --decorate";
      "glgp" = "git log --graph --decorate --oneline --show-pulls --";

      "glgd" = "git log --graph --pretty='${gFormat}' -19";
      "glgdd" = "git log --graph --pretty='${gFormat}'";
      "glgds" = "git log --graph --pretty='${gFormat}' --stat";
      "gls" = "git log --stat | bat --style=plain";
      "glsp" = "git log --stat -p";
      "glcount" = "git shortlog -sn";

      # git-diff
      "gd" = "git diff";
      # gdz: forgit
      "gdw" = "git diff --word-diff";
      "gds" = "git diff --staged";
      "gdst" = "git diff --stat";
      "gdsw" = "git diff --staged --word-diff";
      "gdl" = "git difftool";
      "gdt" = "git diff-tree --no-commit-id --name-only -r";

      # git-blame
      # gbl                  git blame -b -w
      # gbl (forgit)

      # gst: git-status
      "gs" = "git status --short --branch --untracked-files=all";
      "gst" = "git status --short --branch --untracked-files=all";

      # gsh: git-show
      "gsh" = "git show --no-abbrev-commit";
      "gshp" = "git show --no-abbrev-commit --pretty=short --show-signature";

      # git-bisect
      "gbs" = "git bisect";
      "gbsb" = "git bisect bad";
      "gbsg" = "git bisect good";
      "gbsr" = "git bisect reset";
      "gbss" = "git bisect start";

      ############################################################################
      # commit/branch-related
      ############################################################################
      # gc: git-commit; -v: diff 를 gitcommit 에 넣어줌
      "gc" = "git commit -v";
      "gca" = "git commit -v --amend";
      "gcaN" = "git commit -v --amend --no-edit";
      "gcm" = "git commit -v -m";

      # git-cherry-pick
      # gcp                  git cherry-pick
      # gcp: forgit
      "gcpA" = "git cherry-pick --abort";
      "gcpc" = "git cherry-pick --continue";

      # git-merge
      "gm" = "git merge";
      "gmA" = "git merge --abort";
      "gmt" = "git mergetool --no-prompt";
      "gmtvim" = "git mergetool --no-prompt --tool=vimdiff";
      "gmom" = "git merge origin/master";
      "gmum" = "git merge upstream/main";

      # git-rebase
      # grb                git rebase
      # grb (forgit)       interactive `git rebase -i` selector (forgit)
      "grbA" = "git rebase --abort";
      "grbc" = "git rebase --continue";
      "grbi" = "git rebase -i";
      "grbm" = "git rebase main";
      "grbs" = "git rebase --skip";

      # git-revert
      # grev                 git revert
      # grev (forgit)

      # git-branch
      "gb" = "git branch";
      "gbm" = "git branch --move";
      "gba" = "git branch --all";
      "gbnm" = "git branch --no-merged";
      "gbr" = "git branch --remote";
      # gbd : git branch --delete
      # gbd : (forgit)
      "gbd!" = "git branch --delete --force";
      # "gbdm" = "git-branch-delete-merged";

      # git-tag
      "gts" = "git tag -s";
      "gtv" = "git tag | sort -V";

      ############################################################################
      # HEAD 조작; git-tag
      ############################################################################
      # gsw: git-switch
      # gsw                git switch
      # gsw (forgit)
      "gswc" = "git switch -c";
      # gsw                  git branch | sed 's/^[[:space:]*]*//' | fzf --header="current: $(git branch --show-current)" --preview='git log --oneline --color=always {}' | xargs git switch
      # gswt (forgit)
      # gswco (forgit)

      # grs: git-reset
      # "grs" = "git reset"; (forgit)
      "grhd" = "git reset HEAD";
      "grH" = "git reset --hard";
      # gru                  git reset --
      # groh                 git reset origin/$(git_current_branch) --hard
      "grsHhd" = "git reset --hard HEAD";
      "grsHhd1" = "git reset --hard HEAD~1";

      ############################################################################
      # git-stash
      ############################################################################
      # gss: git-stash
      "gssu" = "git stash --include-untracked"; # -u: --include-untracked
      "gssl" = "git stash list";
      "gsso" = "git stash pop";
      # gsss forgit -- show
      # gssp forgit -- push

      # gsta                 git stash save
      # gstaa                git stash apply
      # gstc                 git stash clear
      # gstd                 git stash drop
      # gsts                 git stash show --text
      # gstall               git stash --all

      ############################################################################
      # Remote repository related
      ############################################################################
      # git-remote
      "gre" = "git remote -v";
      "grea" = "git remote add";
      "gremv" = "git remote rename";
      "grerm" = "git remote remove";
      "greset" = "git remote set-url";
      "greup" = "git remote update";

      # git-push
      "gP" = "git push";
      "gPu" = "git push upstream";
      "gPv" = "git push -v";
      "gP!" = "git push --force-with-lease";
      "gPd" = "git push --dry-run";
      "gPoat" = "git push origin --all && git push origin --tags";
      # gpsup                git push --set-upstream origin $(git_current_branch)
      # ggpush               git push --set-upstream origin HEAD

      # git-fetch
      "gf" = "git fetch";
      "gfa" = "git fetch --all --prune";
      "gfo" = "git fetch origin";

      # gpl: git-pull
      "gplf" = "git pull --ff-only";
      "gplr" = "git pull --rebase -v";
      "gplra" = "git pull --rebase --autostash -v";
      # glum                 git pull upstream master
      # ggpull               git pull origin "$(git_current_branch)"
      # ggpush               git push origin "$(git_current_branch)"

      # gcl: git-clone
      "gcl" = "git clone --recurse-submodules";
      "gclm" = "git clone --depth 1 --recurse-submodules --shallow-submodules";

      ############################################################################
      # misc
      ############################################################################
      # git-submodule
      "gsui" = "git submodule init";
      "gsur" = "git submodule update --recursive";
      "gsuu" = "git submodule update";

      "gcf" = "git config --list";
      "gfg" = "git ls-files | grep";
      "gg" = "git gui citool";
      "ggA" = "git gui citool --amend";
      "ghp" = "git help";
      "gwch" = "git whatchanged -p --abbrev-commit --pretty=medium";
      "gignore" = "git update-index --assume-unchanged";
      "gunignore" = "git update-index --no-assume-unchanged";
      "gignored" = "git ls-files -v | grep \"^[[:lower:]]\"";
      "gpristine!" = "git reset --hard && git clean -dfx";
      "gdct" = "git describe --tags \$(git rev-list --tags --max-count=1)";
      # gap                  git apply
      # ggsup                git branch --set-upstream-to=origin/$(git_current_branch)
      # "gke" = "\gitk --all \$(git log -g --pretty=%h)";

      # misc using forgit
      # gclean               git clean -id
      # grl                  git reflog
      # gclean (forgit)
      # greflog (forgit) `git reflog`
      # gignoredgenerate (forgit)
      # gfixup (forgit)

      ############################################################################
      # new -commands
      ############################################################################
      "gtl" = "git-tag-list";
      "gcr" = "git-cd-root";
      "gwip" = "git-wip";
      "gunwip" = "git-unwip";
      "gtodo" = "git-todo";
      "gop" = "git open";
      # "ge" = ''vi $(git_status_select)''; # WIP: not working
    };
in
{
  imports = [
  ];

  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = with pkgsUnstable; [
      git-open
      git-filter-repo
      git-crypt
      git-lfs

      # commitlint
      # gitlint # broken 2025-04-09
      # gitleaks

      # git-annex
      # bup

      # gitu # it freezes
      lazygit
    ];

    services.flatpak.packages = [
      # opensource git client
      # "com.jetpackduba.Gitnuro" # gpl3, jvm
      # "com.github.Murmele.Gittyup" # mit
      # "org.kde.kommit" # gpl3
      # "de.philippun1.turtle" # gpl3, libadwaita
      # "org.gnome.gitg" # gpl2
    ];

    # bindings https://github.com/wfxr/forgit 참고
    home.shellAliases = gitAliases // {
      lg = "lazygit";
    };

    xdg.configFile."zsh-abbr/user-abbreviations".text = (
      lib.concatLines (lib.mapAttrsToList (key: value: ''abbr "${key}"="${value}"'') gitAliases)
    );

    programs.zsh.sessionVariables = {
      FORGIT_PAGER = "cat"; # delta 는 forgit 에서 사용하면 번잡스럽다.
    };

    programs.zsh.localVariables = {
      forgit_add = "ga"; # defaults
      forgit_branch_delete = "gbd"; # defaults
      forgit_blame = "gbl"; # defaults
      forgit_cherry_pick = "gcp"; # defaults
      forgit_diff = "gdz"; # defaults: `gd`
      forgit_log = "glz";
      forgit_rebase = "grb"; # defaults
      forgit_revert_commit = "grev";
      forgit_reset_head = "grs"; # default: `grh`
      forgit_checkout_file = "grst"; # git-restore (default: `gcf`)
      forgit_stash_show = "gsss"; # default: `gss`
      forgit_stash_push = "gssp"; # default: `gsp`
      forgit_checkout_branch = "gsw"; # git-switch
      forgit_checkout_tag = "gswt";
      forgit_checkout_commit = "gswco";
      forgit_reflog = "greflog";
      forgit_clean = "gclean";
      forgit_ignore = "gignoredgenerate";
      forgit_fixup = "gfixup";
    };

    programs.zsh.initContent = ''
      git-branch-delete-merged () {
        # TODO: fix this <2024-12-31>
        # this does not deletes remote branch
        # https://gist.github.com/schacon/942899
        # https://gist.github.com/ryanc414/f7686d2c97808b41ed8518a5840e2d78

        echo "WIP"
        return

        git branch --no-color --merged | command grep -vE "^(\+|\*|\s*(master|main|develop|dev)\s*$)" | command xargs -n 1 git branch -d
      }

      git-tag-list () {
        git tag --sort=-v:refname -n -l "''${1}*"
      }

      git-cd-root () {
        local cd="cd"

        if command -v __zoxide_z >/dev/null 2>&1; then
          cd="__zoxide_z"
        fi

        "$cd" "$(git rev-parse --show-toplevel || echo .)"
      }

      git-wip () {
        git add --all
        git rm $(git ls-files --deleted) 2> /dev/null
        git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"
      }

      git-unwip () {
        git log -n 1 | grep -q -c -- "--wip--" && git reset 'HEAD~1'
      }

      git-todo () {
        if [ -z "$*" ]; then
          echo "Usage: git-todo <msg>"
          return
        fi

        git commit --allow-empty --no-verify --no-gpg-sign -m "--wip-- TODO: $*"
      };

      ${builtins.readFile ./scripts/git-status-select.sh}

      . "${pkgsUnstable.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh"
    '';
  };
}
