{pkgs, ...}: {
  home.stateVersion = "24.11";

  programs.niri = {
    enable = true;
  };
}
