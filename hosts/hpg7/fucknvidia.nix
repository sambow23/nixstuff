{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.extraModprobeConfig = lib.mkForce ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  services.udev.extraRules = lib.mkForce ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x1d34", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
  boot.blacklistedKernelModules = lib.mkForce ["nouveau" "nvidia"];

  systemd.services.removeNouveau = {
    description = "Remove Nouveau driver on startup";
    after = ["network.target"]; # You can specify dependencies here
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/rmmod nouveau";
      RemainAfterExit = true;
    };
  };
}
