{ config, inputs, ... }:
{
  imports = [
    "${inputs.snowflakes}/modules/nixos/aero/services.nix"
  ];

  nixpkgs.overlays = [
    (import "${inputs.snowflakes}/modules/nixos/overlays/aero.nix" {
      waylandEnabled = config.services.aero.wayland.enable;
    })
  ];
}
