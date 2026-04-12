{config, ...}: {
  sops.secrets."wireguard/p5540/private-key" = {
    owner = "root";
    mode = "0400";
  };

  sops.templates."wg-env" = {
    content = ''
      WG_KEY=${config.sops.placeholder."wireguard/p5540/private-key"}
    '';
    owner = "root";
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.sops.templates."wg-env".path
    ];
    profiles = {
      p5540 = {
        connection = {
          id = "p5540";
          type = "wireguard";
          interface-name = "p5540";
          autoconnect = "true";
        };
        wireguard = {
          private-key-flags = "0";
          private-key = "$WG_KEY";
        };
        "wireguard-peer.Alp7aLuxtLiMA7qB4WhNafyfQ2fUDosvsoPMYaPS/EI=" = {
          endpoint = "crdingus.workisboring.com:51820";
          allowed-ips = "0.0.0.0/0;";
          persistent-keepalive = "21";
        };
        ipv4 = {
          method = "manual";
          address1 = "10.0.0.16/32";
          dns = "192.168.50.31;";
        };
        ipv6 = {
          method = "disabled";
          addr-gen-mode = "default";
        };
      };
    };
  };
}
