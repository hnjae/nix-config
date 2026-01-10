{ inputs, ... }:
{ lib, ... }:
let
  nvimConfigSrc = "${inputs.dotfiles}/profiles/00-default/xdg-config/nvim";
  snippetDrv = builtins.path {
    name = "nvim-snippets";
    path = "${nvimConfigSrc}/snippets";
    filter = path: type: lib.hasSuffix ".json" path || type == "directory";
  };
in
{
  plugins.cmp.settings = {
    sources = [
      { name = "luasnip"; }
    ];
    snippet = {
      expand = "function(args) require('luasnip').lsp_expand(args.body) end";
    };
  };

  plugins.luasnip = {
    enable = true;
    fromVscode = [
      { paths = snippetDrv; }
    ];
    settings = {
      store_selection_keys = "<Tab>";
    };
  };

  keymaps = [
    {
      mode = [ "n" ];
      key = "<Tab>";
      action =
        lib.nixvim.mkRaw # lua
          ''
            function()
              local luasnip = require("luasnip")
              if luasnip.locally_jumpable(1) then
                luasnip.jump(1)
              end
            end
          '';
      options = {
        desc = "luasnip-next";
      };
    }

    {
      mode = [ "n" ];
      key = "<S-Tab>";
      action =
        lib.nixvim.mkRaw # lua
          ''
            function()
              local luasnip = require("luasnip")
              if luasnip.locally_jumpable(-11) then
                luasnip.jump(-1)
              end
            end
          '';
      options = {
        desc = "luasnip-prev";
      };
    }
  ];
}
