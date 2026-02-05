{ config, pkgs, lib, ... }:

{
  # Use mesa-git for graphics on t14s
  hardware.graphics = {
    enable = true;
    enable32Bit = false; # ARM64 doesn't need 32-bit support
    package = pkgs.mesa-git;
  };
}
