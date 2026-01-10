{ lib, ... }:
{

  keymaps = lib.flatten [
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
    # Window
    {
      mode = [ "n" ];
      key = "<Leader>|";
      action = "<cmd>vsplit<CR>";
      options = {
        silent = true;
        remap = true;
        desc = "vsplit";
      };
    }
    {
      mode = [ "n" ];
      key = "<Leader>-";
      action = "<cmd>split<CR>";
      options = {
        silent = true;
        remap = true;
        desc = "split";
      };
    }
    {
      mode = [ "n" ];
      key = "<Leader>wd";
      action = "<C-w>c";
      options = {
        remap = true;
        desc = "delete-window";
      };
    }
  ];
  extraConfigLua = ''
    vim.keymap.set("n", "[b",         "<cmd>bprevious<cr>", { desc = "prev-buffer" })
    vim.keymap.set("n", "]b",         "<cmd>bnext<cr>",     { desc = "next-buffer" })
    vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>",       { desc = "switch-to-other-buffer" })
    vim.keymap.set("n", "<leader>`",  "<cmd>e #<cr>",       { desc = "switch-to-other-buffer" })

    vim.keymap.set("n", "<leader><tab>f",     "<cmd>tabfirst<cr>",    { desc = "first-tab" })
    vim.keymap.set("n", "<leader><tab>l",     "<cmd>tablast<cr>",     { desc = "last-tab" })
    vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>",      { desc = "new-tab" })
    vim.keymap.set("n", "<leader><tab>d",     "<cmd>tabclose<cr>",    { desc = "close-Tab" })
    vim.keymap.set("n", "<leader><tab>o",     "<cmd>tabonly<cr>",     { desc = "close-other-tab" })
    vim.keymap.set("n", "<leader><tab>]",     "<cmd>tabnext<cr>",     { desc = "next-Tab" })
    vim.keymap.set("n", "<leader><tab>[",     "<cmd>tabprevious<cr>", { desc = "prev-Tab" })
  '';
}
