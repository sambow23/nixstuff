{hostname, ...}: {
  _module.args = {inherit hostname;};

  imports = [
    ./browser.nix
    ./git.nix
    ./packages.nix
    ./shell.nix
    ./theme.nix
    ./hypr.nix
    ./vscodium.nix
  ];

  # for da touchscreen
  wayland.windowManager.hyprland.plugins = [
  pkgs.hyprlandPlugins.hyprgrass
  ];


  home.username = "cr";
  home.homeDirectory = "/home/cr";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
