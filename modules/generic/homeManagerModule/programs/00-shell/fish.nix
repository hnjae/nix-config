{lib, ...}: {
  programs.fish = {
    enable = false;

    # NOTE: shellInit -> loginShellInit(konsole에서는 source x) ->  interactiveShellInit (2023-04-19 checked)

    shellInit = lib.concatLines [
      ''
        # set -U fish_greeting
        fish_vi_key_bindings
      ''
    ];

    # NOTE: loginShellInit won't be sourced while using terminal like konsole
    # loginShellInit:: config.fish 의 ``status --is-login; and begin ... end`` 안에 들어감
    loginShellInit = "";

    # interactiveShellInit:: config.fish 에서 alias 다음에 들어감
    interactiveShellInit = lib.concatLines [
      ''
        # interactiveShellInit start

        # Remove history
        # https://github.com/fish-shell/fish-shell/issues/2788#issuecomment-191396678
        # https://github.com/fish-shell/fish-shell/issues/5924
        # NOTE: 이 함수는 $XDG_CONFIG_HOME/fish/functions 에 넣어서는 매 prompt 마다 동작하지 않음.
        # 2023-08-02
        # fish_preexec 말고 fish_prompt 를 사용하자. 2023-08-02
        function delete_history --on-event fish_prompt
          for cmd in rm trash trash-put s cd yd ydlocal fg bg nae
            for his in $(history search --prefix -- "$cmd ")
              history delete --exact --case-sensitive -- "$his"
            end
          end

          # for cmd in "./" "../" "/"
          #   for his in $(history search --prefix -- "$cmd")
          #     history delete --exact --case-sensitive -- "$his"
          #   end
          # end

          for cmd in clear exit
            history delete --exact --case-sensitive -- "$his"
          end
        end
      ''
    ];
    # interactiveShellInit = '' '';
    # plugins = with pkgs; [
    # fishPlugins.fzf-fish
    # fishPlugins.fzf
    # ];
    # plugins = with pkgs.fishPlugins; [
    # fish-async-prompt
    # colored-man-pages
    # ];
    # shellAbbrs
    # shellAliases
  };
}
