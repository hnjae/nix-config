{...}: {
  home.shellAliases = {
    ls = builtins.concatStringsSep " " [
      "eza"
      "--smart-group"
      "--links"
      "--time-style long-iso"
      "--color=automatic"
      "--icons=never"
      "--mounts"
      "--extended"
    ];
    # NOTE: lsd does not use terminal colos in some case <2023-10-05; lsd v0.23.1>
    l = builtins.concatStringsSep " " [
      "eza"
      "--smart-group"
      "--links"
      "--time-style long-iso"
      "--color=always"
      "--icons=always"
      "--git"
      "--mounts"
      "--extended"
      # "--group-directories-first"
    ];
    ll = "l --long";
    la = "l -a";
    lt = "l --tree";
    lla = "l -la";
    tree = "eza --tree";
  };
}
