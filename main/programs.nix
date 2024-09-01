{ config, pkgs, inputs, ... }:

let
  # Workaround stupid NVIDIA driver bug breaking Chromium/Electron apps on Wayland
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

  # Workaround stupid NVIDIA driver bug breaking Chromium/Electron apps on Wayland
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
  nvidia-sway = pkgs.symlinkJoin {
    name = "nvidia-sway";
    paths = [
      (pkgs.writeTextFile {
        name = "nvidia-sway-desktop-entry";
        destination = "/share/wayland-sessions/nvidia-sway.desktop";
        text = ''
          [Desktop Entry]
          Name=Sway on NVIDIA
          Comment=An i3-compatible Wayland compositor
          Exec=${pkgs.writeShellScript "nvidia-sway" ''
            export MOZ_ENABLE_WAYLAND=1
            export XDG_CURRENT_DESKTOP=sway
            export XDG_SESSION_DESKTOP=sway
            export XDG_SESSION_TYPE=wayland
            exec ${pkgs.sway}/bin/sway --unsupported-gpu
          ''}
          Type=Application
        '';
      })
    ];
    passthru.providedSessions = [ "nvidia-sway" ];
  };
in

{
  programs.dconf.enable = true;
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
    gnome-disk-utility
    openconnect
    remmina
    wineWowPackages.stable
    grim
    slurp
    wl-clipboard
    mako
    networkmanagerapplet
    pavucontrol
    sway
    waybar
    swaylock
    swaybg
    xed
    fuzzel
    swappy
    firefox
    htop
    gamescope
    polkit_gnome
    font-manager
    bc
    brightnessctl
  ];

    services.displayManager.sessionPackages = [ nvidia-sway ];

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
    floorp-unwrapped
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
        ${pkgs.alacritty}/bin/alacritty -e sh -c "cd /home/cr/nixstuff && sudo nixos-rebuild switch --flake .\\#p5540 --accept-flake-config; echo 'Press any key to close'; read -n 1"
      ''}";
      categories = ["System"];
    })
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