{
  config,
  pkgs,
  ...
}: {
  programs.dconf.enable = true;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    chroma
    eza
    atuin
    python312
    nix-search-cli
    ninja
    clang
    pkg-config
    gtk3
    adwaita-icon-theme
    obs-studio
    gcc
    pciutils
    usbutils
    nil
    alejandra
    lm_sensors
    nix-init
    gnome-disk-utility
    remmina
    wineWowPackages.stable
    grim
    slurp
    wl-clipboard
    mako
    pavucontrol
    waybar
    swaylock
    swaybg
    xed
    fuzzel
    swappy
    htop
    gamescope
    polkit_gnome
    font-manager
    bc
    playerctl
    pamixer
    glib
    lxappearance-gtk2
    pywal16
    imagemagick
    killall
    pipes
    grc
    fzf
    sqlite
    gamemode
    mangohud
    mesa-demos
    vulkan-tools
    mpv
    nwg-displays
    nwg-look
    prismlauncher-unwrapped
    file-roller
    zulu
    gitkraken
    pulseaudio
    localsend
    alejandra
    sonobus
    krita
    distrobox
    feishin
    mesa
    code-cursor
  ];

  programs.nix-ld.enable = true;

  # Distrobox
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Power
  services.cpupower-gui.enable = true;

  # FISHY FISHY
  programs.fish.enable = true;
  users.users.cr.shell = pkgs.fish;

  # ily flatpaks
  services.flatpak.enable = true;

  # GDM
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Swaylock stuff
  security.rtkit.enable = true;
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  programs = {
    hyprland.enable = true; # enable Hyprland
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    fantasque-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.noto
    nerd-fonts.hack
    nerd-fonts.ubuntu
  ];

  # Thunar everything
  programs.xfconf.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # programs.niri.enable= true;
  services.atuin.enable = true;

  users.users.cr.packages = with pkgs; [
    git
    discord
    fastfetch
    clang
    gimp
    parsec-bin
    goofcord
    (pkgs.makeDesktopItem {
      name = "nixos-rebuild";
      desktopName = "NixOS Rebuild";
      comment = "Rebuild NixOS configuration";
      icon = "system-software-update";
      exec = "${pkgs.writeShellScript "nixos-rebuild-wrapper" ''
        ${pkgs.alacritty}/bin/alacritty -e sh -c "cd $HOME/nixstuff && sudo nixos-rebuild switch --flake .\\#${config.networking.hostName} --accept-flake-config; echo 'Command finished. Press any key to close'; read -n 1"
      ''}";
      categories = ["System"];
    })
  ];

  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';
}
