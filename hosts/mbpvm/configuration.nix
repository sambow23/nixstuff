{
  config,
  pkgs,
  lib,
  ...
}: let
  vm-resolution-sync = pkgs.writeShellScriptBin "vm-resolution-sync" ''
    # Path to the resolution file shared from macOS
    RESOLUTION_FILE="/mnt/hgfs/res/resolution.txt"
    DISPLAY_NAME="Virtual-1"

    # Set to 0 to disable logging, 1 to enable
    ENABLE_LOGGING=0
    RESOLUTION_LOG="/home/cr/vm_resolution_log.txt"

    # Function for conditional logging
    log() {
      if [ "$ENABLE_LOGGING" -eq 1 ]; then
        echo "$(date): $1" >> $RESOLUTION_LOG
      fi
    }

    # Create log file if logging is enabled
    if [ "$ENABLE_LOGGING" -eq 1 ]; then
      touch $RESOLUTION_LOG
      chmod 644 $RESOLUTION_LOG
    fi

    # Function to check if a resolution mode is available
    resolution_available() {
        local width=$1
        local height=$2
        local mode="''${width}x''${height}"

        # First check if resolution is already available directly
        if ${pkgs.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep -q "$mode"; then
            log "Resolution $mode is already available"
            return 0
        fi

        # Try to query for the resolution with -q flag
        ${pkgs.xrandr}/bin/xrandr -q | ${pkgs.gnugrep}/bin/grep -q "$mode"
        return $?
    }

    # Function to switch to a resolution using -s flag
    switch_resolution() {
        local width=$1
        local height=$2
        local mode="''${width}x''${height}"

        # Get current resolution
        CURRENT_RESOLUTION=$(${pkgs.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep -w "current" | ${pkgs.gawk}/bin/awk '{print $8 "x" $10}' | ${pkgs.gnused}/bin/sed 's/,//')

        log "Current resolution: $CURRENT_RESOLUTION, Target: $mode"

        # Only switch if it's different
        if [ "$CURRENT_RESOLUTION" != "$mode" ]; then
            log "Attempting to switch to resolution $mode using -s flag"

            # First try using the -s flag directly
            ${pkgs.xrandr}/bin/xrandr -s $mode
            if [ $? -eq 0 ]; then
                log "Successfully switched to $mode using -s flag"
                return 0
            fi

            log "Direct -s switch failed, trying with --output and --mode"

            # If that fails, try with --output and --mode
            ${pkgs.xrandr}/bin/xrandr --output $DISPLAY_NAME --mode $mode
            if [ $? -eq 0 ]; then
                log "Successfully switched using --output and --mode"
                return 0
            fi

            log "Failed to switch to resolution $mode"
            return 1
        else
            log "Already using resolution $mode"
            return 0
        fi
    }

    # Function to add a custom resolution if needed
    add_custom_resolution() {
        local width=$1
        local height=$2
        local mode="''${width}x''${height}"

        # Skip if already exists
        if resolution_available $width $height; then
            return 0
        fi

        log "Adding custom resolution $mode"

        # Calculate VESA CVT mode line
        MODELINE=$(${pkgs.libxcvt}/bin/cvt $width $height 60 | ${pkgs.gnugrep}/bin/grep Modeline | ${pkgs.gawk}/bin/awk '{$1=""; print substr($0,2)}')
        MODE_NAME=$(echo $MODELINE | ${pkgs.gawk}/bin/awk '{print $1}')

        # Create new mode
        log "Adding new mode: $MODE_NAME - $MODELINE"
        ${pkgs.xrandr}/bin/xrandr --newmode $MODELINE
        if [ $? -ne 0 ]; then
            log "Failed to create new mode $mode"
            return 1
        fi

        # Add mode to the display
        log "Adding mode $MODE_NAME to $DISPLAY_NAME"
        ${pkgs.xrandr}/bin/xrandr --addmode $DISPLAY_NAME $MODE_NAME
        if [ $? -ne 0 ]; then
            log "Failed to add mode $mode to $DISPLAY_NAME"
            return 1
        fi

        log "Successfully added resolution $mode"
        return 0
    }

    # Main loop
    while true; do
        # Check if resolution file exists
        if [ -f "$RESOLUTION_FILE" ]; then
            # Read the resolution
            RESOLUTION=$(${pkgs.coreutils}/bin/cat $RESOLUTION_FILE)
            if [ -n "$RESOLUTION" ]; then
                # Parse width and height
                WIDTH=$(echo $RESOLUTION | ${pkgs.coreutils}/bin/cut -d'x' -f1)
                HEIGHT=$(echo $RESOLUTION | ${pkgs.coreutils}/bin/cut -d'x' -f2)

                log "Read resolution from file: $WIDTH x $HEIGHT"

                # Check if the resolution is valid
                if [[ $WIDTH =~ ^[0-9]+$ ]] && [[ $HEIGHT =~ ^[0-9]+$ ]]; then
                    # First try direct switch with -s flag
                    if ! switch_resolution $WIDTH $HEIGHT; then
                        # If that fails, try to add the custom resolution and switch again
                        add_custom_resolution $WIDTH $HEIGHT
                        switch_resolution $WIDTH $HEIGHT
                    fi
                else
                    log "Invalid resolution format: $RESOLUTION"
                fi
            fi
        else
            log "Resolution file not found at $RESOLUTION_FILE"
        fi

        # Wait for 5 seconds
        ${pkgs.coreutils}/bin/sleep 5
    done
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ../../main/system/programs-arm64.nix
    ../../main/system/network.nix
  ];

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mbpvm";

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
    extraGroups = ["networkmanager" "wheel" "docker"];
  };

  systemd.user.services.mask-power-manager = {
    description = "Mask XFCE Power Manager";
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.systemd}/bin/systemctl --user mask xfce4-power-manager.service'";
      RemainAfterExit = true;
    };
  };

  # Create a systemd service to run the resolution sync script
  systemd.services.vm-resolution-sync = {
    description = "VM Resolution Synchronization Service";
    after = ["display-manager.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${vm-resolution-sync}/bin/vm-resolution-sync";
      Restart = "always";
      User = "cr";
      Environment = "DISPLAY=:0";
      # Add RuntimeDirectory to ensure we have permissions
      RuntimeDirectory = "vm-resolution-sync";
      # Redirect stdout and stderr to /dev/null
      StandardOutput = "null";
      StandardError = "null";
    };
  };

  environment.xfce.excludePackages = [pkgs.xfce.xfce4-power-manager];

  # VM Stuff
  virtualisation.vmware.guest.enable = true;

  system.stateVersion = "25.05";
}
