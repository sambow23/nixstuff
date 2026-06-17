{pkgs, ...}: let
  headlessEdid = pkgs.runCommand "headless-edid" {} ''
    mkdir -p $out/lib/firmware/edid
    cp ${./g80sd-emu.bin} $out/lib/firmware/edid/g80sd-emu.bin
  '';
in {
  hardware.nvidia.modesetting.enable = true;

  # Make the EDID available as edid/g80sd-emu.bin.
  hardware.display.edid.packages = [headlessEdid];

  # Force a specific physical DRM connector.
  hardware.display.outputs."DP-1".edid = "g80sd-emu.bin";
  hardware.display.outputs."DP-1".mode = "3840x2160@120e";

  # Make sure the EDID is also available in initrd for early KMS.
  boot.initrd.extraFirmwarePaths = ["edid/g80sd-emu.bin"];
}
