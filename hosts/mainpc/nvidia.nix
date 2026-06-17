# nvidia.nix
{
  config,
  inputs,
  pkgs,
  ...
}: let
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.beta;
in {
  nixpkgs.overlays = [
    inputs.nvidia-patch.overlays.default
  ];

  services.xserver.videoDrivers = ["nvidia"];
  boot.blacklistedKernelModules = ["nouveau"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = pkgs.nvidia-patch.patch-nvenc (pkgs.nvidia-patch.patch-fbc nvidiaPackage);
  };
}
