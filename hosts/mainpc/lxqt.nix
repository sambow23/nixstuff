{
  config,
  pkgs,
  ...
}: {
  services.xserver.desktopManager.lxqt.enable = true;
  xdg.portal.lxqt.enable = true;

  environment.systemPackages = with pkgs; [
    lxqt.lxqt-wayland-session
  ];
}
