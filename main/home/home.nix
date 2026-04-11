{
  hostname,
  inputs,
  lib,
  pkgs,
  ...
}: {
  _module.args = {inherit hostname;};

  imports = [
    ./git.nix
    ./shell.nix
    ./theme.nix
    ./hypr.nix
    ./vscodium.nix
  ];

  home.packages = with pkgs; [
    age
    sops
  ];

  home.username = "cr";
  home.homeDirectory = "/home/cr";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
