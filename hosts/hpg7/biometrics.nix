{
  lib,
  pkgs,
  ...
}: let
  vfs0090Driver = pkgs.libfprint-2-tod1-vfs0090;
in {
  services.fprintd = lib.mkIf (!(vfs0090Driver.meta.broken or false)) {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = vfs0090Driver;
    };
  };
}
