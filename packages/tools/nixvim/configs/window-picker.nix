{ pkgs }:
{
  extraPlugins = with pkgs.vimPlugins; [ nvim-window-picker ];
  extraConfigLua = ''
    require("window-picker").setup({
      show_prompt = false,
      hint = "floating-big-letter",
      selection_chars = "neitsrhodaylkfv",
      filter_rules = {
        include_current_win = true,
      },
    })
  '';
  keymaps = [
    {
      key = "<Space>p";
      mode = "n";
      action = {
        __raw = ''
          function()
            local picked_window_id = require("window-picker").pick_window()
            if picked_window_id == nil then
              return
            end
            vim.api.nvim_set_current_win(picked_window_id)
          end
        '';
      };
    }
  ];
}
