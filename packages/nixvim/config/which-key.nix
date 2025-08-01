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
      spec = [
        {
          __unkeyed-1 = "<leader>w";
          proxy = "<c-w>";
          expand = {
            __raw = ''
              function()
                return require("which-key.extras").expand.win()
              end
            '';
          };
        }
      ];
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
