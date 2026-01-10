{ lib, ... }:
{
  plugins = {
    mini-icons.enable = false;
    web-devicons.enable = false;

    marks = {
      enable = true;
    };

    lualine = {
      enable = true;
      settings = {
        options = {
          always_show_tabline = true;
          icons_enabled = false;
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

    bufferline = {
      enable = true;
      settings = {
        options = {
          style_preset = {
            __unkeyed-1 =
              lib.nixvim.mkRaw # lua
                ''
                  require("bufferline").style_preset.no_italic
                '';
            __unkeyed-2 =
              lib.nixvim.mkRaw # lua
                ''
                  require("bufferline").style_preset.no_bold
                '';
            always_show_bufferline = true;
            show_tab_indicators = true;
            pick = {
              alphabet = "ntesiroahduflpywNTESIROAHDUFLPYW";
            };
          };
        };
      };
    };
  };
}
