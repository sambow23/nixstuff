{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-marketplace; [
      bpat86.nightcall
      jnoortheen.nix-ide
      kamadorueda.alejandra
    ];
  };
}
