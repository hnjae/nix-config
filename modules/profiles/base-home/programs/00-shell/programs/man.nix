let
  function = ''
    function m(){
      vim -c 'execute "normal! :let no_man_maps = 1\<cr>:runtime ftplugin/man.vim\<cr>:Man '"$*"'\<cr>:wincmd o\<cr>"'
    }
  '';
in
{
  programs.zsh.initExtra = function;
  programs.bash.initExtra = function;
}
