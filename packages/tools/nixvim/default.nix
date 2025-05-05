/*
  fallback editor using nixvim
  treesitter 사용이 힘든 매우 큰 파일이나, formatter 를 쓰지 않고 파일을 편집할 용도
*/

{
  nixvim,
  pkgs,
  lib,
}:
let

  recursiveMerge =
    let
      mergeTwo =
        let
          f =
            leftVal: rightVal:
            if (lib.isAttrs leftVal && lib.isAttrs rightVal) then
              mergeTwo leftVal rightVal
            else if (lib.isList leftVal && lib.isList rightVal) then
              leftVal ++ rightVal
            # FIXME:
            # else if (lib.isString leftVal && lib.isString rightVal) then
            #   builtins.concatStringsSep "\n" [
            #     leftVal
            #     rightVal
            #   ]
            else if (rightVal != null) then
              rightVal
            else
              leftVal;
          op =
            outSet: items:
            (
              outSet
              // {
                "${items.name}" = f (outSet."${items.name}") items.value;
              }
            );
        in
        set1: set2: (builtins.foldl' op (set2 // set1) (lib.attrsToList set2));

    in
    builtins.foldl' mergeTwo { };

  package = nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvim (recursiveMerge [
    (import ./configs/flash.nix)
    # ((import ./configs/window-picker.nix) { inherit pkgs; })
    (import ./configs/comment.nix)
    {
      # nixpkgs.useGlobalPackages = true;

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
        vim.g.maplocalleader = "\\"

        --
        local COLORFGBG = os.getenv("COLORFGBG")
        if COLORFGBG == "15;0" then
          vim.opt.background = "dark"
        else
          vim.opt.background = "light"
        end
        --
      '';

      keymaps = lib.flatten [
        {
          action = "<cmd>w<CR><esc>";
          key = "<C-s>";
          mode = [
            "n"
            "i"
            "s"
            "x"
          ];
          options.desc = "save file";
        }
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
          key = "<F23>";
          mode = [
            "n"
            "x"
          ];
          action = ''"+p'';
        }
        (builtins.map
          (key: {
            mode = [ "n" ];
            key = "<C-${key}>";
            action = "<C-w>${key}";
            options = {
              remap = true;
              desc = "<C-w>${key}";
            };
          })
          [
            "h"
            "j"
            "k"
            "l"
          ]
        )
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

      colorschemes = {
        # colorschemes that have light and dark version
        gruvbox.enable = false;
        modus.enable = false;
        melange.enable = false; # gray background
        nightfox.enable = false;
        one.enable = false; # whitish background
        rose-pine.enable = false;
        everforest.enable = false; # yellowish background
        vscode.enable = true; # whitish background
      };

      # extraFiles = import ./share/ftplugin.nix;

      plugins = {
        web-devicons.enable = false;

        sleuth = {
          enable = true;
          settings = { };
        };

        # nvim-autopairs.enable = true;
        nvim-surround.enable = true;

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
              { name = "async_path"; }
              { name = "buffer"; }
            ];
          };

          cmdline = {
            "/" = {
              mapping = {
                __raw = "cmp.mapping.preset.cmdline()";
              };
              sources = [ { name = "buffer"; } ];
            };
            ":" = {
              mapping = {
                __raw = "cmp.mapping.preset.cmdline()";
              };
              sources = [
                { name = "cmdline"; }
                { name = "aync_path"; }
              ];
            };
          };
        };
        cmp-async-path.enable = true;
        cmp-buffer.enable = true;
        cmp-cmdline.enable = true;

        marks = {
          enable = true;
        };

        lightline = {
          enable = false;
        };

        lualine = {
          enable = true;
          settings = {
            options = {
              always_show_tabline = true;
              icons_enabled = false;
              theme = "auto";
              component_separators = {
                left = "┃";
                right = "┃";
              };
              section_separators = {
                left = "";
                right = "";
              };
            };
          };
        };

        telescope = {
          enable = true;
          extensions = {
            fzf-native.enable = true;
            ui-select.enable = true;
          };
        };

        treesitter.enable = false; # 큰 파일 수정할때 매우 느려짐.
        lsp.enable = false;
      };
    }
  ]);
in
pkgs.runCommandLocal "vim" { } ''
  mkdir -p "$out/bin"
  ln -s "${package}/bin/nvim" "$out/bin/vim"
  ln -s "${package}/bin/nvim" "$out/bin/nvim"
  ln -s "${package}/bin/nvim" "$out/bin/vi"
  ln -s "${package}/bin/nvim" "$out/bin/nano"
''
