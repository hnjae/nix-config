{
  colorschemes = {
    vscode = {
      enable = true;
    };
  };

  plugins = {
    marks = {
      enable = true;
    };
    lualine = {
      enable = true;
      settings = {
        options = {
          always_show_tabline = true;
          icons_enabled = false;
          theme = "codedark";
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
  };
}
