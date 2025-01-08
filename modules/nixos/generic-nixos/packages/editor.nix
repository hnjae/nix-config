{pkgs, ...}: {
  # disable nano
  programs.nano.enable = false;

  environment.systemPackages = with pkgs; [nixvim];
}
