let
  sw2 = ''
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
  '';
  sw4 = ''
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
  '';
in
{
  extraFiles = {
    "ftplugin/just.lua".text = sw4;
    "ftplugin/python.lua".text = sw4;

    "ftplugin/asciidoc.lua".text = sw2;
    "ftplugin/asciidoctor.lua".text = sw2;
    "ftplugin/json.lua".text = sw2;
    "ftplugin/kdl.lua".text = sw2;
    "ftplugin/lua.lua".text = sw2;
    "ftplugin/markdown.lua".text = sw2;
    "ftplugin/nix.lua".text = sw2;
    "ftplugin/sh.lua".text = sw2;
    "ftplugin/yaml.lua".text = sw2;
    "ftplugin/zsh.lua".text = sw2;
  };
}
