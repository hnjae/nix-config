# fallback editor using nixvim
{
  config,
  inputs,
  pkgs,
  ...
}: let
  # TODO: formatoptions 는 autocmd 로 관리 <2024-07-31>
  cfg = config."generic-home";
  package = inputs.nixvim.legacyPackages.${pkgs.stdenv.system}.makeNixvim {
    enableMan = false;
    extraConfigLua = ''
      vim.opt.smarttab = true

      vim.opt.smartindent = false
      vim.opt.cindent = false
      vim.opt.autoindent = true

      vim.opt.hlsearch = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true

      vim.opt.ruler = true
      vim.opt.number = true
      vim.opt.relativenumber = true

      vim.opt.undofile = false
      vim.opt.swapfile = false
      vim.opt.backup = false

      -- default: .wbut ?
      vim.opt.complete = ".,w,b,u,t,i"

      -- formatoptions 는 쉽게 override 된다.
      vim.opt.formatoptions:remove("r")
      vim.opt.formatoptions:remove("o")

      vim.opt.mouse = ""
      vim.opt.cursorline = true
      vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:block"

      vim.opt.foldlevel = 999 -- default 0 (fold-all)

      --
      vim.g.loaded_ruby_provider = 0 -- disable ruby
      vim.g.loaded_python_provider = 0 -- disable python2
      vim.g.loaded_python3_provider = 0  -- disable python3
      vim.g.loaded_perl_provider = 0 -- disable perl
      vim.g.loaded_node_provider = 0 -- disable node

      vim.g.mapleader = " "
      vim.g.maplocalleader = "s"
    '';

    keymaps = [
      {
        action = ":";
        key = "<Leader><Leader>";
        mode = ["n" "v"];
      }
    ];

    colorschemes = {
      base16 = {
        enable = true;
        colorscheme =
          # https://github.com/RRethy/base16-nvim/
          # https://glitchbone.github.io/vscode-base16-term/#/twilight
          if (cfg.base24.enable && config.base24.variant == "light")
          then "default-light"
          else "default-dark";
      };
    };

    # extraFiles = import ./share/ftplugin.nix;

    plugins = {
      # nvim-autopairs.enable = true;
      surround.enable = true;

      cmp.enable = true;
      # cmp-treesitter.enable = true;
      cmp-async-path.enable = true;
      cmp-buffer.enable = true;
      cmp-cmdline.enable = true;

      treesitter = {
        enable = false;
        folding = true;
      };

      marks = {enable = true;};

      lualine = {
        enable = true;
        iconsEnabled = false;
        componentSeparators = {
          left = "┃";
          right = "┃";
        };
        sectionSeparators = {
          left = "";
          right = "";
        };
        theme = "base16";
      };

      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
        };
      };

      lsp.enable = false;
    };
  };
  output = pkgs.writeScriptBin "vim" ''
    #!${pkgs.dash}/bin/dash
     ${package}/bin/nvim "$@"
  '';
in {
  home.packages = [output];
  home.shellAliases = {nano = "vim";};
}
