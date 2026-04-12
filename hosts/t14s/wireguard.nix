{config, ...}: {
  # Define the secret
  sops.secrets."wireguard/t14s/private-key" = {
    owner = "root";
    mode = "0400";
  };

  networking.wg-quick.interfaces.wg0 = {
    privateKeyFile = config.sops.secrets."wireguard/t14s/private-key".path;
    address = ["10.0.0.16/32"];
    dns = ["192.168.50.31"];
    peers = [
      {
        publicKey = "Alp7aLuxtLiMA7qB4WhNafyfQ2fUDosvsoPMYaPS/EI=";
        endpoint = "47.221.73.179:51820";
        allowedIPs = ["0.0.0.0/0"];
      }
    ];
  };
}
