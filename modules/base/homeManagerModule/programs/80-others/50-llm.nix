{
  pkgsUnstable,
  lib,
  pkgs,
  ...
}:
{
  home.packages = builtins.concatLists [
    (with pkgsUnstable; [
      shell-gpt # https://github.com/TheR1D/shell_gpt
      chatgpt-cli # support chatgpt,gemini,ollama # https://github.com/npiv/chatblade/
      gtt # uses chatgpt to translate
      #
      tgpt # support openai, ollma
      # oterml # ollama client - not in nixpkgs 2024-08-07
    ])
    (lib.optionals pkgs.stdenv.isLinux (
      with pkgsUnstable;
      [
        jan
      ]
    ))
  ];
}
