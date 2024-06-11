{pkgs, ...}: {
  home.stateVersion = "24.11";

  programs.niri.settings = {
    input.touchpad = {
      dwt = true;
      tap = false;
      click-method = "clickfinger";
    };
    hotkey-overlay.skip-at-startup = false;
  };
}
