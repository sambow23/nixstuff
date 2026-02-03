{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../main/system/programs-arm64.nix
    ../../main/system/network.nix
    ../../main/system/flatpak.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "t14s";

  nix.settings.experimental-features = ["nix-command" "flakes"];

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

  # Enable the X1E hardware support
  hardware.lenovo-thinkpad-t14s.enable = true;

  # Temp Plasma
  services.desktopManager.plasma6.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  users.users.cr = {
    isNormalUser = true;
    description = "cr";
    extraGroups = ["networkmanager" "wheel" "docker" "libvirtd"];
  };

  users.mutableUsers = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable all firmware
  hardware.enableAllFirmware = true;

  # t14s audio
  environment.sessionVariables = let
    yogaslim7x-ucm-conf = pkgs.alsa-ucm-conf.overrideAttrs (oldAttrs: {
      name = "alsa-ucm-conf-custom";
      postPatch =
        oldAttrs.postPatch or ""
        + ''
          substituteInPlace ucm2/codecs/qcom-lpass/wsa-macro/four-speakers/init.conf \
            --replace "84" "5"
          substituteInPlace ucm2/codecs/qcom-lpass/wsa-macro/init.conf \
            --replace "84" "5"
        '';
    });
  in {
    ALSA_CONFIG_UCM2 = "${yogaslim7x-ucm-conf}/share/alsa/ucm2";
  };

  systemd.user.services.disable-audio-compressors = {
    description = "Disable audio compressors";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    after = ["wireplumber.service"];
    wants = ["wireplumber.service"];
    script = ''
      sleep 5
      ${pkgs.alsa-utils}/bin/amixer -c 0 sset 'RX_COMP1' off
      ${pkgs.alsa-utils}/bin/amixer -c 0 sset 'RX_COMP2' off
      ${pkgs.alsa-utils}/bin/amixer -c 0 sset 'WSA WSA_COMP1' off
      ${pkgs.alsa-utils}/bin/amixer -c 0 sset 'WSA WSA_COMP2' off
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/51-speaker-volume-limit.lua" ''
      alsa_monitor.rules = {
        {
          matches = {
            {
              { "node.name", "equals", "alsa_output.platform-sound.HiFi__Speaker__sink" },
            },
          },
          apply_properties = {
            ["api.alsa.soft-mixer"] = true,
            ["channelVolumes.max"] = 0.1,
          },
        },
      }
    '')
  ];

  # KVM/virtualization support
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?
}
