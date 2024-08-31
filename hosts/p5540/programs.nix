{ config, pkgs, inputs, ... }:

{
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    chroma
    eza
    atuin
    python312
    nix-search-cli
    lightly-boehs
    ninja
    clang
    pkg-config
    gtk3
    gnome.adwaita-icon-theme
    obs-studio
    vlc
    gcc
    pciutils
    usbutils
    nil
    alejandra
    lm_sensors
    undervolt
    tlp
    nix-init
    distrobox
    docker-compose
    gnome.gnome-disk-utility
    openconnect
    remmina
    wineWowPackages.stable
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    networkmanagerapplet
    pavucontrol
    sway
    waybar
    swaylock
    swaybg
    foot
    xed
    fuzzel
    nerdfonts
    swappy
    firefox
  ];

  programs.xfconf.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  boot.kernelPackages = pkgs.linuxPackages_zen;

  environment.variables = {
    ZSH_COLORIZE_TOOL = "chroma";
  };

  # programs.niri.enable= true;
  services.atuin.enable = true;

  users.users.cr.packages = with pkgs; [
    kate
    vscodium
    git
    discord
    fastfetch
    clang
    gimp
    parsec-bin
    vesktop
    inputs.thorium-avx.packages.${pkgs.system}.default
  ];

  programs.zsh = {
    enable = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "colored-man-pages"
        "z"
      ];
    };

    shellAliases = {
      ls = "eza -a --long --header --git --icons=always";
      nix-gc = "nix-store --gc --print-roots | awk '{print $1}' | grep /result$ | sudo xargs rm";
    };
  };

  users.users.cr.shell = pkgs.zsh;

  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';
}
