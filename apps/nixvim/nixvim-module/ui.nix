{
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
