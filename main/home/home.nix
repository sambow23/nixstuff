{ config, pkgs, inputs, hostname, ... }:
{
  _module.args = { inherit hostname; };

  imports = [
    ./browser.nix
    ./git.nix
    ./packages.nix
    ./shell.nix
    ./theme.nix
    ./hypr.nix
  ];

  home.username = "cr";
  home.homeDirectory = "/home/cr";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
