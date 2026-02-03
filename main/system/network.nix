{pkgs, ...}: {
  # fuck wpa_supplicant
  networking.wireless.enable = false;

  # Enable networking
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    settings = {
      device = {
        "wifi.iwd.autoconnect" = true;
      };
      connection = {
        "wifi.cloned-mac-address" = "preserve";
      };
    };
  };

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

  # iwd
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        ControlPortOverNL80211 = false;
        EnableNetworkConfiguration = false;
      };
      Settings = {
        AutoConnect = false;
      };
    };
  };

  networking.resolvconf.dnsExtensionMechanism = false;

  # Network System Packages
  environment.systemPackages = with pkgs; [
    openconnect
    networkmanagerapplet
    openiscsi
  ];
}
