{ config, lib, pkgs, hostname, ... }:
let
  mainMod = "SUPER";
  # Helper function to generate workspace bindings
  workspaceBinds = builtins.concatLists (builtins.genList (i:
    let
      num = if i == 9 then "0" else toString (i + 1);
      ws = toString (i + 1);
    in [
      "${mainMod}, ${num}, workspace, ${ws}"
      "${mainMod} SHIFT, ${num}, movetoworkspace, ${ws}"
    ]
  ) 10);

  # Host-specific monitor settings
  hostDisplays = if hostname == "hpg7" then {
    monitor = [
      "eDP-1,1920x1080@60.0,0x0, 1"
    ];
  } else if hostname == "mainpc" then {
    monitor = [
      "HDMI-A-1, preferred, 2560x1440@60, 0x0, 1"
      "DP-1, preferred, 1920x1080@60, 2560x0, 1"
    ];
  } else if hostname == "p5540" then {
    monitor = [
      "eDP-1,1920x1080@60.0,0x0, 1"
    ];
  } else {
    monitor = [
      # Default monitor settings
    ];
  };
in {
  # Set environment variables
  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
  };

  # Enable Hyprland and set configurations
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Variables
      "$terminal" = "alacritty";
      "$fileManager" = "thunar";
      "$menu" = "fuzzel";
      "$mainMod" = mainMod;

      # Misc settings
      misc = {
        vrr = 2;
        middle_click_paste = false;
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      # Displays
      displays = hostDisplays;

      # Render settings
      render.direct_scanout = false;

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgb(7FB4C2) rgb(C7BFA8) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration settings
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      # Animation settings
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Dwindle layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Master layout settings
      master.new_status = "master";

      # Input settings
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        scroll_points = "0 0";
        scroll_factor = 0.75;
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.25;
          tap-to-click = false;
        };
      };

      # Gesture settings
      gestures.workspace_swipe = true;

      # Device-specific settings
      device = [
        {
          name = "logitech-g502-1";
          sensitivity = 0;
          tap-to-click = false;
          accel_profile = "flat";
        }
        {
          name = "pixart-dell-ms116-usb-optical-mouse";
          sensitivity = 0;
          tap-to-click = false;
          accel_profile = "flat";
        }
      ];

      # Cursor settings
      cursor.enable_hyprcursor = false;

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # Autostart applications
      exec-once = [
        "waybar"
        "swaybg -i /home/cr/nixstuff/wallpapers/darktable_exported/nr-1_02.jpg -m fill"
        "nm-applet"
        "blueman-applet"
      ];
      exec = [
        "swayidle idlehint 1"
        "swayidle -w before-sleep -C ~/.config/swaylock/config"
      ];

      # Keybindings
      bind = [
        "$mainMod, Return, exec, $terminal"
        "$mainMod, Tab, exit"
        "$mainMod, Q, killactive"
        "SUPER_SHIFT, Z, exec, $fileManager"
        "SUPER_SHIFT, Space, togglefloating,"
        "$mainMod, D, exec, $menu"
        "SUPER_SHIFT, J, togglesplit,"
        "$mainMod, F, fullscreen"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioStop, exec, playerctl stop"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", Print, exec, grim -g \"$(slurp)\" - | tee ~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy"
        "SUPER_SHIFT, P, exec, grim -g \"$(slurp)\" - | tee ~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy"
        "$mainMod, P, exec, kate \"/home/cr/nixstuff/main/system/programs.nix\""
        "$mainMod, N, exec, chromium --new-window \"https://mynixos.com/packages\""
        "$mainMod, H, exec, chromium --new-window \"home-manager-options.extranix.com\""
        "$mainMod, K, exec, kate"
        "$mainMod, J, exec, chromium --new-window \"http://192.168.50.192:8096/web/#/music.html\""
        "$mainMod, O, exec, chromium"
      ] ++ workspaceBinds;

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Window rules
      windowrulev2 = [
        "suppressevent maximize, class:.*"
      ];
      windowrule = [
        "float, ^(mpv)$"
        "noblur, ^(waybar)$"
      ];
    };
  };
}
