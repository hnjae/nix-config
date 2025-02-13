{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDev {
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
      pkgs.write-good # markdown
      # textidote # markdown, tex

      # html formatter
      html-tidy

      # asciidoctor
      asciidoctor-with-extensions
    ];
  };
}
