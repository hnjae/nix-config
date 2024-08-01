pkgs:
(pkgs.vim_configurable.override {
  pythonSupport = false;
  luaSupport = false;
  perlSupport = false;
  rubySupport = false;
  netbeansSupport = false;
  guiSupport = null;
  ximSupport = false;
})
.customize {
  name = "vim";
  # pure vim-script minimum environment
  vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
    start = [
      vim-nix
      rainbow

      vim-signature
      jellybeans-vim
      lightline-vim

      vim-better-whitespace
      auto-pairs

      # tpope
      vim-sensible
      vim-commentary
      vim-surround
      vim-repeat
      vim-sleuth
      vim-vinegar
    ];
    opt = [];
  };
  vimrcConfig.customRC = builtins.readFile ./share/vimrc;
}
