{ config, ... }:
let
  cmd = ''timeout 0.05s ${config.home.shellAliases.l} || echo "ls timeout"'';
in
{
  programs.zsh.initContent = ''
    function chpwd_ls() {
      ${cmd}
    }
    chpwd_ls
    chpwd_functions+=(chpwd_ls)
  '';

  # NOTE: programs.fish.functions 에 넣어서는 작동 안함 <2024-02-16>
  # programs.fish.functions.chpwd = {
  #   body = ''
  #       if not status --is-command-substitution ; and status --is-interactive
  #         ${cmd}
  #     end
  #   '';
  #   onVariable = "PWD";
  # };
  programs.fish.interactiveShellInit = ''
    function chpwd_ls --on-variable PWD
      if not status --is-command-substitution ; and status --is-interactive
          ${cmd}
      end
    end
  '';

  # TODO: implement this for bash <2024-02-16>
  # https://stackoverflow.com/questions/3276247/is-there-a-hook-in-bash-to-find-out-when-the-cwd-changes
}
