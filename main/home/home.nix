{ config, pkgs, inputs, ... }:

{
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

  programs.nixvim.enable = true;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
