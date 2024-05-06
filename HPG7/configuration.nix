# gaming pc
{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./programs.nix
      ./pkgs/thorium.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "intel_idle.max_cstate=1"
    "intel_iommu=on"
    "intel_iommu=pt"
    "kvm.ignore_msrs=1"
  ];
  boot.kernelModules = [ "kvm-intel" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.extraModprobeConfig = "options vfio-pci ids=10de:1d34";
  
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.nvidia.prime = {
       sync.enable = false;
       allowExternalGpu = true
       ;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:6:0:0";
  };

  networking.hostName = "crUltraDingusBook"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "intel" "nvidia" ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = false;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.hardware.bolt.enable = true;


  # Sway stuff

  # Create a systemd service for swaylock to autostart
  systemd.user.services.swaylock = {
    description = "Lock screen using swaylock";
    serviceConfig = {
      ExecStart = "${pkgs.swaylock}/bin/swaylock -f";
    };
    wantedBy = [ "default.target" ];
  };
    
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Fingerprint Auth
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.pulseaudio.support32Bit = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cr = {
    isNormalUser = true;
    description = "cr";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    packages = with pkgs; [
      firefox
      kate
    ];
  };


nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-run"
  ];

programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui
    libselinux
    mangohud
    git
    eza
    meslo-lgs-nf
    rare
    lutris
    gnome3.adwaita-icon-theme
    vesktop
    yt-dlp
    temurin-jre-bin-17
    arduino-ide
    kcalc
    btop
    sbsigntool
    bash
    dos2unix
    gedit
    plasma5Packages.plasma-thunderbolt
    comma
    pciutils
    direnv
    home-manager
    swaylock
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };
  
  specialisation = {
    egpu = {
      configuration = {
        system.nixos.tags = ["egpu"];
        boot = {
          blacklistedKernelModules = ["i915"];
          consoleLogLevel = 0;
          kernelParams = [
            "module_blacklist=i915"
            "quiet"
            "udev.log_level=3"
          ];
        };
        services.xserver.videoDrivers = [ "nvidia" ];
      };
    };
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}

