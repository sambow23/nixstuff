{ config, lib, pkgs, inputs, hostname, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-marketplace; [
      bpat86.nightcall
      jeff-hykin.better-nix-syntax
      jnoortheen.nix-ide
      kamadorueda.alejandra
      ]
    ++ (with pkgs.open-vsx; [
      jeanp413.open-remote-ssh
    ]);
  };
}
