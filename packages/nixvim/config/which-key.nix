{
  plugins.which-key = {
    enable = true;
    settings = {
      preset = "helix";
      icons = {
        colors = false;
        mappings = false;
        rules = false;
      };
    };
  };
  keymaps = [
    {
      key = "<Leader>?";
      mode = "n";
      action = {
        __raw = ''
          function()
            require("which-key").show({ global = false })
          end
        '';
      };
      options = {
        desc = "buffer-local keymaps (which-key)";
      };
    }
  ];

}
