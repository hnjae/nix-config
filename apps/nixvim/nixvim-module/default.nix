flakeArgs@{ importApply, ... }:
{
  imports = [
    (importApply ./load-dotfiles.nix flakeArgs)
    ./cmp.nix
    ./lazyvim-keys.nix
    ./snacks-explorer.nix
    ./ui.nix
    ./which-key.nix
    ./window-picker.nix
  ];

  performance = {
    combinePlugins.enable = true;
    byteCompileLua = {
      enable = true;
      configs = true;
      initLua = true;
      nvimRuntime = true;
      plugins = true;
    };
  };
  enableMan = false;

  extraConfigLuaPre = ''
    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"
  '';

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

    vim.g.editorconfig = true -- enabled by default

    --
    local COLORFGBG = os.getenv("COLORFGBG")
    if COLORFGBG == "0;15" then
      vim.opt.background = "light"
    else
      vim.opt.background = "dark"
    end
  '';

  keymaps = [
    {
      key = "<bs>";
      mode = [
        "n"
        "v"
      ];
      action = ":";
      options.desc = "cmdline";
    }
    {
      key = "<F12>";
      mode = [
        "x"
        "s"
      ];
      action = ''"+y'';
    }
    {
      key = "<F24>";
      mode = [
        "n"
        "x"
      ];
      action = ''"+p'';
    }
  ];
  autoCmd = [
    {
      event = [ "FileType" ];
      pattern = [ "man" ];
      callback = {
        __raw = ''
          function()
            vim.opt_local.ruler = true
            vim.opt_local.number = true
            vim.opt_local.relativenumber = true
          end
        '';
      };
    }

    {
      # formatoptions 는 쉽게 override 되어 autocmd 로 설정
      event = [
        "BufRead"
        "BufNewFile"
        "BufNew"
      ];
      pattern = [
        "*"
      ];
      desc = "remove r (enter), o (normal mode o), t (textwidth), c (textwidth-comment) from formatoptions";
      callback = {
        __raw = builtins.concatStringsSep " " [
          "function()"
          ''vim.opt_local.formatoptions:remove("r")''
          ''vim.opt_local.formatoptions:remove("o")''
          ''vim.opt_local.formatoptions:remove("t")''
          ''vim.opt_local.formatoptions:remove("c")''
          "end"
        ];
      };
    }
  ];

  plugins = {
    treesitter.enable = false; # 큰 파일 수정할때 매우 느려짐.
    lsp.enable = false;

    nvim-surround.enable = true;

    sleuth = {
      enable = true;
      settings = { };
    };
  };
}
