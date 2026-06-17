{
  lib,
  pkgs,
  ...
}: {
  programs.labwc.enable = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        enableWaylandSession = true;
      };
    };
  };

  services.libinput.mouse.accelProfile = "flat";

  services.displayManager = {
    defaultSession = "xfce-wayland";
    sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositorCommand = lib.getExe pkgs.labwc;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    catfish
    gigolo
    orage
    xfburn
    xfce4-appfinder
    xfce4-clipman-plugin
    xfce4-cpugraph-plugin
    xfce4-dict
    xfce4-fsguard-plugin
    xfce4-genmon-plugin
    xfce4-netload-plugin
    xfce4-panel
    xfce4-pulseaudio-plugin
    xfce4-systemload-plugin
    xfce4-weather-plugin
    xfce4-whiskermenu-plugin
    xfce4-xkb-plugin
    xfdashboard
    xev
    xhost
  ];

  programs = {
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-volman
      ];
    };
  };
}
