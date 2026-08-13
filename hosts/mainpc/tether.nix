{pkgs, ...}: let
  upstreamInterface = "eno2";
  downstreamInterface = "eno1";
  downstreamAddress = "10.77.0.1";
  downstreamCidr = "${downstreamAddress}/24";
  downstreamDhcpRange = "10.77.0.10,10.77.0.50,255.255.255.0,12h";
in {
  systemd.network.enable = true;
  systemd.network.networks."10-mainpc-tether" = {
    matchConfig.Name = downstreamInterface;
    address = [downstreamCidr];
    linkConfig.RequiredForOnline = "no";
    networkConfig = {
      DHCP = "no";
      IPv6AcceptRA = false;
      LinkLocalAddressing = "no";
    };
  };

  networking.networkmanager.unmanaged = [downstreamInterface];

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = downstreamInterface;
      bind-dynamic = true;
      listen-address = downstreamAddress;
      port = 0;
      dhcp-authoritative = true;
      dhcp-range = downstreamDhcpRange;
      dhcp-option = [
        "option:router,${downstreamAddress}"
        "option:dns-server,1.1.1.1,9.9.9.9"
      ];
    };
  };

  networking.nat = {
    enable = true;
    externalInterface = upstreamInterface;
    internalInterfaces = [downstreamInterface];
  };

  networking.firewall.extraCommands = ''
    ipt=${pkgs.iptables}/bin/iptables

    $ipt -w -I INPUT 1 -i ${downstreamInterface} -j REJECT
    $ipt -w -I INPUT 1 -i ${downstreamInterface} -p udp -m multiport --dports 67,5353,47998:48000,48002,48010 -j ACCEPT
    $ipt -w -I INPUT 1 -i ${downstreamInterface} -p tcp -m multiport --dports 22,47984:47990,48010 -j ACCEPT
    $ipt -w -I INPUT 1 -i ${downstreamInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    $ipt -w -I FORWARD 1 -o ${downstreamInterface} -j REJECT
    $ipt -w -I FORWARD 1 -i ${downstreamInterface} -j REJECT
    $ipt -w -I FORWARD 1 -i ${downstreamInterface} -o ${upstreamInterface} -j ACCEPT
    $ipt -w -I FORWARD 1 -i ${downstreamInterface} -d 224.0.0.0/4 -j REJECT
    $ipt -w -I FORWARD 1 -i ${downstreamInterface} -d 169.254.0.0/16 -j REJECT
    $ipt -w -I FORWARD 1 -i ${downstreamInterface} -d 192.168.0.0/16 -j REJECT
    $ipt -w -I FORWARD 1 -i ${downstreamInterface} -d 172.16.0.0/12 -j REJECT
    $ipt -w -I FORWARD 1 -i ${downstreamInterface} -d 10.0.0.0/8 -j REJECT
    $ipt -w -I FORWARD 1 -i ${upstreamInterface} -o ${downstreamInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  '';

  networking.firewall.extraStopCommands = ''
    ipt=${pkgs.iptables}/bin/iptables

    $ipt -w -D INPUT -i ${downstreamInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
    $ipt -w -D INPUT -i ${downstreamInterface} -p tcp -m multiport --dports 22,47984:47990,48010 -j ACCEPT || true
    $ipt -w -D INPUT -i ${downstreamInterface} -p udp -m multiport --dports 67,5353,47998:48000,48002,48010 -j ACCEPT || true
    $ipt -w -D INPUT -i ${downstreamInterface} -j REJECT || true

    $ipt -w -D FORWARD -i ${upstreamInterface} -o ${downstreamInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
    $ipt -w -D FORWARD -i ${downstreamInterface} -d 10.0.0.0/8 -j REJECT || true
    $ipt -w -D FORWARD -i ${downstreamInterface} -d 172.16.0.0/12 -j REJECT || true
    $ipt -w -D FORWARD -i ${downstreamInterface} -d 192.168.0.0/16 -j REJECT || true
    $ipt -w -D FORWARD -i ${downstreamInterface} -d 169.254.0.0/16 -j REJECT || true
    $ipt -w -D FORWARD -i ${downstreamInterface} -d 224.0.0.0/4 -j REJECT || true
    $ipt -w -D FORWARD -i ${downstreamInterface} -o ${upstreamInterface} -j ACCEPT || true
    $ipt -w -D FORWARD -i ${downstreamInterface} -j REJECT || true
    $ipt -w -D FORWARD -o ${downstreamInterface} -j REJECT || true
  '';
}
