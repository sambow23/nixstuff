{ config, pkgs, inputs, ... }:

{
  programs.nix-index.enable = true;

  # FISHY FISHY
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      plugins = [
        { name = "grc"; src = pkgs.fishPlugins.grc.src; } # Colorizer
        { name = "bobthefisher" ; src = pkgs.fishPlugins.bobthefisher.src; } # Powerline-style, Git-aware fish theme optimized for awesome (fork of bobthefish)
        { name = "fifc" ; src = pkgs.fishPlugins.fifc.src; } # Fzf powers on top of fish completion engine and allows customizable completion rules
        { name = "puffer" ; src = pkgs.fishPlugins.puffer.src; } # Text Expansions for Fish
        { name = "autopair" ; src = pkgs.fishPlugins.autopair.src; } # Auto-complete matching pairs in the Fish command line
      ];
    };
}
