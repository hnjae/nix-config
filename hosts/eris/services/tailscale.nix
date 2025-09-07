# DOCS: https://tailscale.com/kb/1103/exit-nodes
# NOTE: `openFirewall` 따로 설정 안해도 exit-node 로 잘 작동함. <NixOS 25.05>
{
  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--advertise-exit-node"
    ];
    useRoutingFeatures = "server"; # configures sysctl (`net.ipv6.conf.all.forwarding`)
  };
}
