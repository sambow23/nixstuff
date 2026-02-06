{
  config,
  pkgs,
  ...
}: {
  programs.dconf.enable = true;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    kdePackages.breeze-icons
    chroma
    eza
    python312
    ninja
    clang
    pkg-config
    gtk3
    adwaita-icon-theme
    gcc
    nil
    alejandra
    lm_sensors
    gnome-disk-utility
    remmina
    pavucontrol
    htop
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
    mesa-demos
    mpv
    file-roller
    catfish
    gigolo
    orage
    xfburn
    xfce4-appfinder
    xfce4-clipman-plugin
    xfce4-cpugraph-plugin
    xfce4-dict
    xfce4-fsguard-plugin
    xfce4-genmon-plugin
    xfce4-netload-plugin
    xfce4-panel
    xfce4-pulseaudio-plugin
    xfce4-systemload-plugin
    xfce4-weather-plugin
    xfce4-whiskermenu-plugin
    xfce4-xkb-plugin
    xfdashboard
    xorg.xrandr
    xorg.libxcvt
    gnugrep
    gawk
    gnused
    coreutils
    squashfuse
    distrobox
    vesktop
    feishin
    boxbuddy
    fex
    squashfsTools
    patchelf
    nh
    code-cursor
    easyeffects
    obs-studio
    obsidian
  ];

  # Peak
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # FISHY FISHY
  programs.fish.enable = true;
  users.users.cr.shell = pkgs.fish;

  # ily flatpaks
  services.flatpak.enable = true;

  # GDM
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
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

  fonts.packages = with pkgs; [
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

  services.gnome.gnome-keyring.enable = true;

  users.users.cr.packages = with pkgs; [
    git
    fastfetch
    clang
    gimp
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
