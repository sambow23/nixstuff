{ config, pkgs, inputs, ... }:

{
  # Disable intel-pstate as its laggy as hell with it, worse battery life be damned.

#   boot.kernelParams = ["intel_pstate=disable"];
#   boot.kernelModules = ["acpi-cpufreq"];

#  services.power-profiles-daemon.enable = false;
#   services.tlp = {
#     enable = true;
#     settings = {
#       CPU_SCALING_GOVERNOR_ON_AC = "performance";
#       CPU_SCALING_GOVERNOR_ON_BAT = "performance";
#
#       CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
#       CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
#
#       CPU_MIN_PERF_ON_AC = 100;
#       CPU_MAX_PERF_ON_AC = 100;
#       CPU_MIN_PERF_ON_BAT = 0;
#       CPU_MAX_PERF_ON_BAT = 65;
#     };
#   };

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
