{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      # markdown
      marksman
      markdownlint-cli
      markdownlint-cli2
      cbfmt # format codeblocks inside markdown and org
      mdcat # markdown preview in cli; better than glow as it uses ANSI colors

      # tex/markdown ..
      ltex-ls

      # spellcheck
      codespell # all
      proselint # markdown, tex
      write-good # markdown
      # textidote # markdown, tex

      # html formatter
      html-tidy

      # asciidoctor
      asciidoctor-with-extensions
    ];
  };
}
