{ lib, ... }:
{
  plugins.snacks = {
    enable = true;
    settings.picker.sources.explorer = {
      hidden = true;
      layout = {
        preset = "sidebar";
        layout.width = 40; # default: 50
      };
      actions = {
        explorer_mkfile =
          lib.nixvim.mkRaw # lua
            ''
              function(picker)
                local Tree = require("snacks.explorer.tree")
                local uv = vim.uv or vim.loop

                Snacks.input({
                  prompt = "Add a new file",
                }, function(value)
                  if not value or value:find("^%s$") then
                    return
                  end
                  local path = svim.fs.normalize(picker:dir() .. "/" .. value)
                  local parent_dir = vim.fs.dirname(path)
                  if uv.fs_stat(path) then
                    Snacks.notify.warn("File already exists:\n- `" .. path .. "`")
                    return
                  end

                  vim.fn.mkdir(parent_dir, "p")
                  io.open(path, "w"):close()
                  Tree:open(parent_dir)
                  Tree:refresh(parent_dir)
                  require("snacks.explorer.actions").update(picker, { target = path })
                end)
              end
            '';

        explorer_mkdir =
          lib.nixvim.mkRaw # lua
            ''
              function(picker)
                local Tree = require("snacks.explorer.tree")
                Snacks.input({ prompt = "Add a new directory" }, function(value)
                  if not value or value:find("^%s$") then return end
                  local dir = vim.fs.normalize(picker:dir() .. "/" .. value)
                  vim.fn.mkdir(dir, "p")
                  Tree:open(dir)
                  Tree:refresh(dir)
                  require("snacks.explorer.actions").update(picker, { target = dir })
                end)
              end
            '';
      };
      win.list.keys = {
        # disable defaults
        a = false;
        "<leader>/" = false;
        y = false;
        m = false;
        c = false;

        # file picker 랑 동작 통일
        "<c-t>" = "tab";
        "<c-v>" = "edit_vsplit";
        "<c-s>" = "edit_split";
        "<c-r>" = "terminal";
        "<c-o>" = "edit_split";

        # NEW & replace
        P = "edit_split";
        p = "toggle_preview";
        o = "edit_split";
        H = "list_top";
        v = "edit_vsplit";
        t = "tab";

        "%" = "explorer_mkfile";
        d = "explorer_mkdir";
        D = "explorer_del";

        gx = "explorer_open";
        gh = "toggle_hidden";
        gi = "toggle_ignore";
        I = "toggle_help_input";
        mg = "picker_grep";

        mc = {
          __unkeyed-1 = "explorer_yank";
          mode = [
            "n"
            "x"
          ];
        };
        mp = "explorer_paste";
        gm = "explorer_move";
        gc = "explorer_copy";
        r = "explorer_rename";
      };
    };
  };

  keymaps = lib.flatten [
    {
      mode = [ "n" ];
      key = "<Leader>fe";
      action =
        lib.nixvim.mkRaw # lua
          ''
            function()
              Snacks.explorer()
            end
          '';
      options = {
        desc = "Explorer Snacks (root dir)";
      };
    }
    {
      mode = [ "n" ];
      key = "<Leader>fE";
      action =
        lib.nixvim.mkRaw # lua
          ''
            function()
              Snacks.explorer()
            end
          '';
      options = {
        desc = "Explorer Snacks (cwd)";
      };
    }
    {
      key = "<leader>e";
      action = "<leader>fe";
      options = {
        desc = "Explorer Snacks (root dir)";
      };
    }
    {
      key = "<leader>E";
      action = "<leader>fE";
      options = {
        desc = "Explorer Snacks (cwd)";
      };
    }
  ];
}
