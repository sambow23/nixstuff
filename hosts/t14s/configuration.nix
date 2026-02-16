{
  config,
  pkgs,
  lib,
  inputs,
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

  # Powertop auto-tune (harmless on t14s)
  powerManagement.powertop.enable = true;

  # Override kernel to use jglathe's fork (fixes my touchscreen and suspend issues)
  # Both source and build tools are pinned as flake inputs to avoid rebuilds
  boot.kernelPackages = lib.mkForce (let
    # Use pinned nixpkgs for kernel build to prevent rebuilds on nixpkgs updates
    kernelPkgs = import inputs.nixpkgs-kernel {
      system = pkgs.system;
      config = pkgs.config;
    };
    customKernel = kernelPkgs.linuxPackagesFor (kernelPkgs.buildLinux {
      src = inputs.jglathe-kernel-src;
      version = "6.19.0-rc7-jg";
      modDirVersion = "6.19.0-rc7";

      configfile = ./kernel.config;

      ignoreConfigErrors = true;

      structuredExtraConfig = with lib.kernel; {
        EC_LENOVO_YOGA_SLIM7X = option module;
      };
    });
  in customKernel);

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

  # KDE Connect
  programs.kdeconnect.enable = true;

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

  # t14s audio - patched UCM for jglathe kernel (no DISPLAY_PORT_RX controls)
  environment.sessionVariables = let
    t14s-ucm-conf = pkgs.alsa-ucm-conf.overrideAttrs (oldAttrs: {
      name = "alsa-ucm-conf-t14s-patched";
      postPatch =
        oldAttrs.postPatch or ""
        + ''
          # WSA macro volume fix
          substituteInPlace ucm2/codecs/qcom-lpass/wsa-macro/four-speakers/init.conf \
            --replace "84" "5"
          substituteInPlace ucm2/codecs/qcom-lpass/wsa-macro/init.conf \
            --replace "84" "5"

          # Replace T14s-HiFi.conf to remove DISPLAY_PORT_RX controls
          # (not present in jglathe kernel, causes UCM init failure)
          cp ${./T14s-HiFi.conf} ucm2/Qualcomm/x1e80100/T14s-HiFi.conf

          # Limit speaker PA (power amplifier) gain to protect speakers
          # Default is 12 (+9dB), we set to 1 (-7.5dB)
          substituteInPlace ucm2/codecs/wsa884x/two-speakers/SpeakerSeq.conf \
            --replace "'SpkrLeft PA Volume' 12" "'SpkrLeft PA Volume' 1"
          substituteInPlace ucm2/codecs/wsa884x/two-speakers/SpeakerSeq.conf \
            --replace "'SpkrRight PA Volume' 12" "'SpkrRight PA Volume' 1"

          # Disable all speaker compressors in UCM sequences
          # SpeakerSeq.conf: per-amplifier compressors
          substituteInPlace ucm2/codecs/wsa884x/two-speakers/SpeakerSeq.conf \
            --replace "'SpkrLeft COMP Switch' 1" "'SpkrLeft COMP Switch' 0"
          substituteInPlace ucm2/codecs/wsa884x/two-speakers/SpeakerSeq.conf \
            --replace "'SpkrRight COMP Switch' 1" "'SpkrRight COMP Switch' 0"
          # DefaultEnableSeq.conf: same per-amplifier compressors (SectionVerb init)
          substituteInPlace ucm2/codecs/wsa884x/two-speakers/DefaultEnableSeq.conf \
            --replace "'SpkrLeft COMP Switch' 1" "'SpkrLeft COMP Switch' 0"
          substituteInPlace ucm2/codecs/wsa884x/two-speakers/DefaultEnableSeq.conf \
            --replace "'SpkrRight COMP Switch' 1" "'SpkrRight COMP Switch' 0"
          # Wsa1SpeakerEnableSeq.conf: WSA macro compressors
          substituteInPlace ucm2/codecs/qcom-lpass/wsa-macro/Wsa1SpeakerEnableSeq.conf \
            --replace "'WSA WSA_COMP1 Switch' 1" "'WSA WSA_COMP1 Switch' 0"
          substituteInPlace ucm2/codecs/qcom-lpass/wsa-macro/Wsa1SpeakerEnableSeq.conf \
            --replace "'WSA WSA_COMP2 Switch' 1" "'WSA WSA_COMP2 Switch' 0"
        '';
    });
  in {
    ALSA_CONFIG_UCM2 = "${t14s-ucm-conf}/share/alsa/ucm2";
  };

  # Keep speakers active to prevent amp power-on pop
  systemd.user.services.speaker-keep-alive = {
    description = "Keep speakers active to prevent pop";
    wantedBy = ["wireplumber.service"];
    partOf = ["wireplumber.service"];
    after = ["pipewire.service" "wireplumber.service"];
    wants = ["pipewire.service"];
    script = ''
      # Wait for both speaker amplifiers to initialize over SoundWire
      # SpkrRight is the second amp to enumerate; once it appears, both are ready
      for i in $(seq 1 20); do
        if ${pkgs.alsa-utils}/bin/amixer -c 0 controls 2>/dev/null | grep -q 'SpkrRight PA Volume'; then
          break
        fi
        sleep 1
      done
      sleep 2
      exec ${pkgs.pulseaudio}/bin/paplay --volume=0 --channels=2 --rate=48000 --raw /dev/zero
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };
  };

  # Disable RX path compressors (headphone path, not covered by UCM speaker patches)
  systemd.user.services.disable-audio-compressors = {
    description = "Disable RX path audio compressors";
    wantedBy = ["wireplumber.service"];
    partOf = ["wireplumber.service"];
    after = ["wireplumber.service"];
    script = ''
      sleep 5
      ${pkgs.alsa-utils}/bin/amixer -c 0 sset 'RX_COMP1' off
      ${pkgs.alsa-utils}/bin/amixer -c 0 sset 'RX_COMP2' off
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Force software volume for speakers - prevents PipeWire from touching ALSA mixers
  # ALSA stays at safe fixed level, PipeWire does volume scaling in software
  services.pipewire.wireplumber.extraConfig."51-speaker-softmixer" = {
    "monitor.alsa.rules" = [
      {
        matches = [[ "node.name" "~" "alsa_output.platform-sound.*Speaker.*" ]];
        actions = {
          update-props = {
            "api.alsa.disable-mixer" = true;
            "api.alsa.soft-mixer" = true;
          };
        };
      }
    ];
  };

  # KVM/virtualization support
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?
}
