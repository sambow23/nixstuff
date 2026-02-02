{pkgs, ...}: {
  # Disable intel-pstate as its laggy as hell with it, worse battery life be damned.

  #   boot.kernelParams = ["intel_pstate=disable"];
  #   boot.kernelModules = ["acpi-cpufreq"];

  services.power-profiles-daemon.enable = false;


  # Trying auto-cpufreq out
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
