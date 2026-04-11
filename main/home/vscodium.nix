{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-marketplace; [
      jeff-hykin.better-nix-syntax
      jnoortheen.nix-ide
      kamadorueda.alejandra
    ];
  };
}
