{config, ...}: {
  sops.secrets."wifi/home/ssid" = {};
  sops.secrets."wifi/home/psk" = {};

  networking.networkmanager = {
    ensureProfiles = {
      environmentFiles = [
        config.sops.secrets."wifi/home/ssid".path
        config.sops.secrets."wifi/home/psk".path
      ];

      profiles = {
        "home" = {
          connection = {
            id = "home";
            type = "wifi";
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$HOME_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$HOME_PSK";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            method = "auto";
            addr-gen-mode = "stable-privacy";
          };
        };
      };
    };
  };
}
