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
