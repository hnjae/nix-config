{
  plugins = {
    comment = {
      enable = true;
      settings = {
        mapping = false;
      };
    };
  };
  keymaps = [
    {
      key = "gb";
      mode = "n";
      action = "<Plug>(comment_toggle_blockwise)";
      options.desc = "comment-toggle-blockwise";
    }
    {
      key = "gb";
      mode = "x";
      action = "<Plug>(comment_toggle_blockwise_visual)";
      options.desc = "comment-toggle-blockwise (visual)";
    }
    {
      key = "gc";
      mode = "n";
      action = {
        __raw = ''
          function()
            return vim.api.nvim_get_vvar("count") == 0 and "<Plug>(comment_toggle_blockwise_current)"
              or "<Plug>(comment_toggle_blockwise_count)"
          end
        '';
      };
      options = {
        expr = true;
        desc = "comment-toggle-current-block";
      };
    }
  ];
}
