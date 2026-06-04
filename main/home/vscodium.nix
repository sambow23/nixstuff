{pkgs, ...}: {
  programs.vscodium = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-marketplace; [
      jeff-hykin.better-nix-syntax
      jnoortheen.nix-ide
      kamadorueda.alejandra
    ];
  };
}
