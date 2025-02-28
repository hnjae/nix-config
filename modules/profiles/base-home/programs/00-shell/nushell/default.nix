{ ... }:
{
  programs.nushell = {
    enable = true;
    # settings = {
    #   buffer_editor = "vi";
    # };
    configFile = {
      text = ''
        $env.config.buffer_editor = "vi"
      '';
    };
  };
}
