{
  config,
  pkgs,
  ...
}: {
  programs.dconf.enable = true;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    breeze-icons
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
    grim
    slurp
    wl-clipboard
    mako
    pavucontrol
    waybar
    swaylock
    swaybg
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
    pulseaudio
    localsend
    jellyfin-media-player
    alejandra
    sonobus
    krita
    distrobox
xfce.catfish
xfce.gigolo
xfce.orage
xfce.xfburn
xfce.xfce4-appfinder
xfce.xfce4-clipman-plugin
xfce.xfce4-cpugraph-plugin
xfce.xfce4-dict
xfce.xfce4-fsguard-plugin
xfce.xfce4-genmon-plugin
xfce.xfce4-netload-plugin
xfce.xfce4-panel
xfce.xfce4-pulseaudio-plugin
xfce.xfce4-systemload-plugin
xfce.xfce4-weather-plugin
xfce.xfce4-whiskermenu-plugin
xfce.xfce4-xkb-plugin
xfce.xfdashboard
  ];

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
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    xkb = {
      layout = "us";
      variant = "";
    };
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
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    fantasque-sans-mono
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

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };

  # programs.niri.enable= true;
  services.atuin.enable = true;

  users.users.cr.packages = with pkgs; [
    git
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
