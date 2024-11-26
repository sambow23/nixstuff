{hostname, ...}: let
  mainMod = "SUPER";
  workspaceBinds = builtins.concatLists (builtins.genList (
      i: let
        num =
          if i == 9
          then "0"
          else toString (i + 1);
        ws = toString (i + 1);
      in [
        "${mainMod}, ${num}, workspace, ${ws}"
        "${mainMod} SHIFT, ${num}, movetoworkspace, ${ws}"
      ]
    )
    10);

  defaultMonitorConfig = {
    monitor = [
      "eDP-1,1920x1080@60.0,0x0,1"
    ];
  };

  hostDisplays =
    {
      hpg7 = defaultMonitorConfig;
      mainpc = {
        monitor = [
          "DP-1,1920x1080@240.0,0x0,1.0"
          "DP-2,3840x2160@60.0,1920x0,1.25"
        ];
        workspace = [
          "1,monitor:DP-1"
          "2,monitor:DP-1"
          "3,monitor:DP-2"
          "4,monitor:DP-2"
        ];
      };
      p5540 = defaultMonitorConfig;
      d3301 = defaultMonitorConfig;
      mba = {
        monitor = [
          "eDP-1,1366x768@60.0,0x0,1"
        ];
      };
    }
    .${hostname}
    or {
      monitor = [
      ];
    };

  mediaKeys = [
    ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
    ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
    ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
    ", XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
    ", XF86AudioPlay, exec, playerctl play-pause"
    ", XF86AudioNext, exec, playerctl next"
    ", XF86AudioPrev, exec, playerctl previous"
    ", XF86AudioStop, exec, playerctl stop"
  ];

  brightnessKeys = [
    ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
    ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
  ];
in {
  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$terminal" = "alacritty";
      "$fileManager" = "thunar";
      "$menu" = "fuzzel";
      "$mainMod" = mainMod;

      misc = {
        vrr = 2;
        middle_click_paste = false;
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      plugin.touch_gestures = {
        sensitivity = 4.0;
      };

      displays = hostDisplays;

      render.direct_scanout = false;

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

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master.new_status = "master";

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

      gestures.workspace_swipe = true;

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

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      exec-once = [
        "waybar"
        "swaybg -i /home/cr/nixstuff/wallpapers/darktable_exported/nr-1_02.jpg -m fill"
        "nm-applet"
      ];
      exec = [
        "swayidle idlehint 1"
        "swayidle -w before-sleep -C ~/.config/swaylock/config"
      ];

      bind =
        [
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
        ]
        ++ mediaKeys
        ++ brightnessKeys
        ++ [
          ", Print, exec, grim -g \"$(slurp)\" - | tee ~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy"
          "SUPER_SHIFT, P, exec, grim -g \"$(slurp)\" - | tee ~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy"
          "$mainMod, P, exec, codium \"/home/cr/nixstuff/main/system/programs.nix\""
          "$mainMod, N, exec, chromium --new-window \"https://search.nixos.org/packages\""
          "$mainMod, H, exec, chromium --new-window \"home-manager-options.extranix.com\""
          "$mainMod, K, exec, codium"
          "$mainMod, J, exec, chromium --new-window \"http://192.168.50.192:8096/web/#/music.html\""
          "$mainMod, O, exec, chromium"
        ]
        ++ workspaceBinds;

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

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
