# fallback editor using nixvim
# treesitter 사용이 힘든 매우 큰 파일이나, formatter 를 쓰지 않고 파일을 편집할
# 용도
nixvim: pkgs: let
  package =
    nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvim
    {
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

        --
        local COLORFGBG = os.getenv("COLORFGBG")
        if COLORFGBG == "15;0" then
          vim.opt.background = "dark"
        elseif COLORFGBG ~= nil then
          vim.opt.background = "light"
        end
      '';

      keymaps = [
        {
          action = ":";
          # key = "<Leader><Leader>";
          key = "<Space><Space>";
          mode = ["n" "v"];
          options.desc = "cmdline";
        }
      ];

      autoCmd = [
        {
          # formatoptions 는 쉽게 override 되어 autocmd 로 설정
          # vim.opt.formatoptions:remove("r")
          # vim.opt.formatoptions:remove("o")
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

      colorschemes = {
        gruvbox.enable = true;
      };

      # extraFiles = import ./share/ftplugin.nix;

      plugins = {
        # nvim-autopairs.enable = true;
        surround.enable = true;

        cmp = {
          enable = true;
          settings = {
            mapping = {
              __raw = ''
                cmp.mapping.preset.insert({
                  ["<C-n>"] = cmp.mapping(function()
                    if cmp.visible() then
                      cmp.select_next_item()
                    else
                      cmp.complete()
                    end
                  end, { "i" }),
                  ["<C-p>"] = cmp.mapping(function()
                    if cmp.visible() then
                      cmp.select_prev_item()
                    else
                      cmp.complete()
                    end
                  end, { "i" }),
                })

              '';
            };
            sources = [
              {name = "async_path";}
              {name = "buffer";}
            ];
          };
          cmdline = {
            "/" = {
              mapping = {__raw = "cmp.mapping.preset.cmdline()";};
              sources = [{name = "buffer";}];
            };
            ":" = {
              mapping = {__raw = "cmp.mapping.preset.cmdline()";};
              sources = [
                {name = "cmdline";}
                {name = "aync_path";}
              ];
            };
          };
        };
        cmp-async-path.enable = true;
        cmp-buffer.enable = true;
        cmp-cmdline.enable = true;

        treesitter.enable = false; # 큰 파일 수정할때 매우 느려짐.

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
          theme = "auto";
        };

        telescope = {
          enable = true;
          extensions = {
            fzf-native.enable = true;
            ui-select.enable = true;
          };
        };

        lsp.enable = false;
        # sleuth.enable = true;
      };
    };
in
  pkgs.writeScriptBin "vim" ''
    #!${pkgs.dash}/bin/dash
     ${package}/bin/nvim "$@"
  ''