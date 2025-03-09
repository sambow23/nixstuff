{pkgs, ...}: {
  # Enable networking
  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall = {
    logReversePathDrops = true;
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    '';
    allowedTCPPorts = [80 443 7860]; # Stable Diffusion Forge
  };

  networking.resolvconf.dnsExtensionMechanism = false;

  # Network System Packages
  environment.systemPackages = with pkgs; [
    openconnect
    networkmanagerapplet
    openiscsi
  ];
}
