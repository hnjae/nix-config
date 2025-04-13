{
  plugins = {
    flash = {
      enable = true;
      settings = {
        labels = "setnriaodhfuplwyc,vkx.gmbq;/jz"; # sorted by colemak-dh typing effort
      };
    };
  };
  keymaps = [
    {
      key = "s";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = {
        __raw = ''function() require("flash").jump() end'';
      };
      options.desc = "flash";
    }
    {
      key = "r";
      mode = "o";
      action = {
        __raw = ''function() require("flash").remote() end'';
      };
      options.desc = "flash";
    }
    {
      key = "<C-s>";
      mode = "c";
      action = {
        __raw = ''function() require("flash").toggle() end'';
      };
      options.desc = "flash";
    }
  ];
}
