# nvidia.nix
{config, ...}: {
  services.xserver.videoDrivers = ["amdgpu" "nvidia"]; # AMD first, then NVIDIA

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # AMD GPU is primary
      amdgpuBusId = "PCI:108:0:0";
      nvidiaBusId = "PCI:2:0:0";
    };
  };

  # Early KMS
  boot.initrd.kernelModules = ["amdgpu"];

  # AMD GPU configuration
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # Fix hardware video accel
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # Optional: Add kernel parameters
  boot.kernelParams = [
    "amdgpu.gpu_recovery=1"
    "amdgpu.prefergpu=1"
  ];
}
