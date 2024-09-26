{ config, pkgs, inputs, ... }:

{
  # Disable intel-pstate as its laggy as hell with it, worse battery life be damned.

  boot.kernelParams = ["intel_pstate=disable"];
  boot.kernelModules = ["acpi-cpufreq"];

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "performance";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "performance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 100;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 100;
      CPU_MAX_PERF_ON_BAT = 100;
    };
  };

  # Hardware Video Accel for Intel iGPUs
    environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Laptop system packages
  environment.systemPackages = with pkgs; [
  brightnessctl
  tlp
  undervolt
  ];
}
