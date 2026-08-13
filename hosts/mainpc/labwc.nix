{
  lib,
  pkgs,
  ...
}: let
  labwcDisplayLayout = pkgs.writeShellScript "mainpc-labwc-displays" ''
    if [ -z "''${WAYLAND_DISPLAY:-}" ] || [ -z "''${LABWC_PID:-}" ]; then
      exit 0
    fi

    for _ in 1 2 3 4 5; do
      if ${lib.getExe pkgs.wlr-randr} \
        --output HDMI-A-1 --on --mode 1280x720@60Hz --pos 0,0 --scale 1 \
        --output DP-1 --on --custom-mode 3840x2160@120Hz --right-of HDMI-A-1 --scale 1; then
        exit 0
      fi

      sleep 1
    done

    exit 0
  '';
  sunshineAutostart = pkgs.writeShellScript "mainpc-sunshine-autostart" ''
    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      exit 0
    fi

    envVars=(
      DBUS_SESSION_BUS_ADDRESS
      DISPLAY
      PATH
      WAYLAND_DISPLAY
      XAUTHORITY
      XDG_CURRENT_DESKTOP
      XDG_RUNTIME_DIR
      XDG_SESSION_DESKTOP
      XDG_SESSION_TYPE
    )

    ${pkgs.systemd}/bin/systemctl --user import-environment "''${envVars[@]}" || true
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd "''${envVars[@]}" || true
    ${pkgs.systemd}/bin/systemctl --user reset-failed sunshine.service || true
    ${pkgs.systemd}/bin/systemctl --user restart sunshine.service
  '';
in {
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

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.xwayland.enable = true;

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
    wlr-randr
    xfdashboard
    kdePackages.qtwayland
    xev
    xhost
  ];

  environment.etc."xdg/autostart/mainpc-labwc-displays.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=MainPC Labwc displays
    Exec=${labwcDisplayLayout}
    OnlyShowIn=XFCE;
    NoDisplay=true
    X-XFCE-Autostart-enabled=true
  '';

  environment.etc."xdg/autostart/mainpc-sunshine.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=MainPC Sunshine
    Exec=${sunshineAutostart}
    OnlyShowIn=XFCE;
    NoDisplay=true
    X-XFCE-Autostart-enabled=true
  '';

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
