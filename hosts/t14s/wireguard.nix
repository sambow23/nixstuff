{config, ...}: {
  sops.secrets."wireguard/t14s/private-key" = {
    owner = "root";
    mode = "0400";
  };

  sops.templates."wg-env" = {
    content = ''
      WG_KEY=${config.sops.placeholder."wireguard/t14s/private-key"}
    '';
    owner = "root";
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.sops.templates."wg-env".path
    ];
    profiles = {
      t14s = {
        connection = {
          id = "t14s";
          type = "wireguard";
          interface-name = "t14s";
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
          address1 = "10.0.0.3/32";
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
