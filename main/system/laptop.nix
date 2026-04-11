{pkgs, ...}: {
  # auto-cpufreq
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  # Hardware Video Accel for Intel iGPUs (i do not have any AMD nix'ed laptops)
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Laptop system packages
  environment.systemPackages = with pkgs; [
    brightnessctl
    tlp
    undervolt
    powertop
  ];
}
