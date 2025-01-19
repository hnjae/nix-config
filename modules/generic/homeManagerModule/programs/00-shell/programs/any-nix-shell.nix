{pkgs, ...}: {
  programs.fish.shellInit = ''
    ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
  '';

  # nix-shell 에서 zsh 사용할 수 있게 해줌
  programs.zsh.initExtra = ''
    ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
  '';
}
