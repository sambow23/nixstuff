{
  config,
  pkgs,
  inputs,
  ...
}: let
  # Cant believe i still need these
  vesktop-nvidia = pkgs.writeShellScriptBin "vesktop-nvidia" ''
    ${pkgs.vesktop}/bin/vesktop --use-angle=opengl "$@"
  '';

  vesktop-nvidia-desktop = pkgs.makeDesktopItem {
    name = "vesktop-nvidia";
    desktopName = "Vesktop (NVIDIA)";
    exec = "${vesktop-nvidia}/bin/vesktop-nvidia";
    icon = "vesktop";
    comment = "Vesktop with NVIDIA Wayland workaround";
  };

  vscodium-nvidia = pkgs.writeShellScriptBin "codium-nvidia" ''
    ${pkgs.vscodium}/bin/codium --use-angle=opengl "$@"
  '';

  vscodium-nvidia-desktop = pkgs.makeDesktopItem {
    name = "vscodium-nvidia";
    desktopName = "VSCodium (NVIDIA)";
    exec = "${vscodium-nvidia}/bin/codium-nvidia";
    icon = "vscodium";
    comment = "VSCodium with NVIDIA Wayland workaround";
  };

    nvidia-hyprland = pkgs.symlinkJoin {
    name = "nvidia-hyprland";
    paths = [
      (pkgs.writeTextFile {
        name = "nvidia-hyprland-desktop-entry";
        destination = "/share/wayland-sessions/nvidia-hyprland.desktop";
        text = ''
          [Desktop Entry]
          Name=Sway on NVIDIA
          Comment=An i3-compatible Wayland compositor
          Exec=${pkgs.writeShellScript "nvidia-hyprland" ''
            export MOZ_ENABLE_WAYLAND=1
            export XDG_CURRENT_DESKTOP=hyprland
            export XDG_SESSION_DESKTOP=hyprland
            export XDG_SESSION_TYPE=wayland
            export AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1
            export WLR_DRM_DEVICES=/dev/dri/card0:/dev/dri/card1
            exec ${pkgs.hyprland}/bin/hyprland
          ''}
          Type=Application
        '';
      })
    ];
    passthru.providedSessions = ["nvidia-hyprland"];
  };
in {
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
    distrobox
    docker-compose
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
    prismlauncher-unwrapped
    file-roller
    zulu
    gitkraken
    pulseaudio
  ];

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
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerdfonts
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

  boot.kernelPackages = pkgs.linuxPackages_zen;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
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
    vesktop-nvidia
    vesktop-nvidia-desktop
    vscodium-nvidia
    vscodium-nvidia-desktop
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
