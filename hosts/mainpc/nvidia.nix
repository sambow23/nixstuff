# nvidia.nix
{
  config,
  ...
}: {
  services.xserver.videoDrivers = ["nvidia"];
  boot.blacklistedKernelModules = ["nouveau"];

  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker.daemon.settings.features.cdi = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
