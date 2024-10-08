{
  config,
  pkgs,
  inputs,
  ...
}: {
  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  services.flatpak.packages = [
    "com.moonlight_stream.Moonlight"
    "org.prismlauncher.PrismLauncher"
  ];
}
