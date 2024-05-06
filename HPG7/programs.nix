# gaming pc: programs.nix

{ lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  users.users.cr.packages = with pkgs; [
    google-chrome
    discord
    vscodium
    zsh-powerlevel10k
    fastfetch
    prismlauncher
  ];

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = ''
      fastfetch
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';

    shellAliases = {
      ls = "eza -alh";
    };

    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };
  users.users.cr.shell = pkgs.zsh;


  # Misc
  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';
}
