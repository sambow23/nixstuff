{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-marketplace; [
      bpat86.nightcall
      jeff-hykin.better-nix-syntax
      jnoortheen.nix-ide
      kamadorueda.alejandra
    ];
  };
}
