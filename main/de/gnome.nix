{
  config,
  pkgs,
  ...
}: {
  services.desktopManager.gnome.enable = true;

  services.gnome.core-apps.enable = true;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  services.gnome.gnome-keyring.enable = true;
  environment.gnome.excludePackages = with pkgs; [gnome-tour gnome-user-docs];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    pkgs.gnomeExtensions.dash-to-panel
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.clipboard-indicator
  ];
}
