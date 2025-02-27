{ ... }:
{
  programs.nushell = {
    enable = false;
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
