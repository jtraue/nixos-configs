{ config, lib, pkgs, ... }:


# For unicode symbols go to https://unicode-table.com
# Search for your symbol
#   example: battery - number U+1F50B
# Insert in vim via: Ctrl+v U1f50b (+space)
let
  cfg = config.home-modules.desktop.i3;
  solarizedColors = config.home-modules.desktop.solarized;
  inherit (pkgs.stdenv) mkDerivation;

  theme-select = "-theme $(cat ~/.rofi.theme)";

  inherit (pkgs) onboard-keyboard-control;
  inherit (pkgs) theme-switch;

  # XXX:
  # This should probably be an overlay but I cannot figure out how
  # to use overlays in home-manager.
  i3exit = mkDerivation rec {
    # take manjaro's i3 exit script
    name = "i3exit";
    version = "0.1";

    src = builtins.fetchGit {
      url = "https://gitlab.manjaro.org/packages/community/i3/i3exit.git";
      rev = "0b0e62d437debe4b88da7d52878b7db3ebf0f254"; #
      ref = "master";
    };
    phases = [ "install" "fixupPhase" ];
    install = ''
      mkdir -p $out/bin
      cp $src/i3exit $out/bin
      chmod +x $out/bin/i3exit
    '';
  };

  modifier = "Mod4";
in
{

  options.home-modules.desktop.i3.enable = lib.mkEnableOption "Enables i3.";

  config = lib.mkIf cfg.enable {

    # notification daemon for send-notify
    services.dunst = {
      enable = true;
      settings =
        {
          global = {
            markup = true;
            plain_text = false;
            indicate_hidden = true;
            alignment = "center";
            follow = "mouse";
            separator_height = 2;
            line_height = 3;
            padding = 20;
            horizontal_padding = 6;
            separator_color = "foreground";

            geometry = "300x50-12+30";
            transparency = 5;
            frame_color = "${solarizedColors.base00}";
            frame_width = 3;
            fonts = [ "pango:Cantarell 12" ];
          };

          urgency_low = {
            background = "${solarizedColors.base03}";
            foreground = "${solarizedColors.base00}";
            timeout = 5;
          };
          urgency_normal = {
            background = "${solarizedColors.base03}";
            foreground = "${solarizedColors.yellow}";
            frame_color = "${solarizedColors.yellow}";
            timeout = 10;
          };
          urgency_critical = {
            background = "${solarizedColors.base03}";
            foreground = "${solarizedColors.orange}";
            frame_color = "${solarizedColors.orange}";
            timeout = 20;
          };
        };
    };

    home.packages = with pkgs;[
      xautolock
      betterlockscreen
      i3status-rust
      i3
      siji
      xautolock
    ];

    xsession.enable = true;
    xsession.windowManager.i3 = {
      enable = true;

      config = {
        bars = [
          {
            position = "top";
            colors = {
              background = "${solarizedColors.base03}";
              statusline = "${solarizedColors.base0}";
              activeWorkspace = {
                background = "${solarizedColors.base02}";
                border = "${solarizedColors.base02}";
                text = "${solarizedColors.base00}";
              };
              bindingMode = {
                background = "${solarizedColors.base3}";
                border = "${solarizedColors.base00}";
                text = "${solarizedColors.base00}";
              };
              focusedWorkspace = {
                background = "${solarizedColors.base0}";
                border = "${solarizedColors.base0}";
                text = "${solarizedColors.base03}";
              };
              inactiveWorkspace = {
                background = "${solarizedColors.base02}";
                border = "${solarizedColors.base02}";
                text = "${solarizedColors.base00}";
              };
              urgentWorkspace = {
                background = "${solarizedColors.orange}";
                border = "${solarizedColors.orange}";
                text = "${solarizedColors.dark}";
              };
            };
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs";
            fonts = {
              names = [ "pango:DejaVu Sans Mono" ];
              size = 10.0;
            };
          }
        ];

        colors = {
          focused = {
            background = "${solarizedColors.base03}";
            border = "${solarizedColors.base1}";
            childBorder = "${solarizedColors.base1}";
            indicator = "${solarizedColors.base03}";
            text = "${solarizedColors.base1}";
          };
          unfocused = {
            background = "${solarizedColors.magenta}";
            border = "${solarizedColors.base01}";
            childBorder = "${solarizedColors.base02}";
            indicator = "${solarizedColors.base03}";
            text = "${solarizedColors.green}";
          };
          focusedInactive = {
            background = "${solarizedColors.base00}";
            border = "${solarizedColors.base00}";
            childBorder = "${solarizedColors.base00}";
            indicator = "${solarizedColors.base03}";
            text = "${solarizedColors.base1}";
          };
          urgent = {
            background = "${solarizedColors.base03}";
            border = "${solarizedColors.orange}";
            childBorder = "${solarizedColors.orange}";
            indicator = "${solarizedColors.base03}";
            text = "${solarizedColors.orange}";
          };
        };

        floating = {
          criteria = [
            { class = "qemu"; }
            { class = "Pavucontrol"; }
            { class = "Simple-scan"; }
            { class = "Toplevel"; } # beopardy
            { class = "toplevel*"; } # beopardy
          ];
        };

        fonts = {
          names = [ "pango:Cantarell" ];
          size = 12.0;
        };

        keybindings = lib.mkOptionDefault {
          "${modifier}+Return" = "exec kitty";
          "${modifier}+p" = "exec --no-startup-id ${pkgs.rofi-pass}/bin/rofi-pass";
          "${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -modi drun#run#ssh -combi-modi drun#run -show combi -show-icons -display-combi run ${theme-select}";
          "${modifier}+x" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -modi window -show window -auto-select ${theme-select}";
          "XF86MonBrightnessUp" = "exec light -s sysfs/backlight/intel_backlight -A 10";
          "XF86MonBrightnessDown" = "exec light -s sysfs/backlight/intel_backlight -U 10";
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+s" = "split h; exec ${pkgs.libnotify}/bin/notify-send 'tile horizontally'";
          "${modifier}+v" = "split v; exec ${pkgs.libnotify}/bin/notify-send 'tile vertically'";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+Shift+e" = "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'\"";
          "${modifier}+r" = "mode \"resize\"";
          # Thinkpad controls
          "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +5% #increase sound volume";
          "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -5% #decrease sound volume";
          "XF86AudioMute" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle # mute sound";
          "XF86Explorer" = "exec ~/.local/bin/toggletouchpad.sh # toggle touchpad";
          "XF86AudioPlay" = "exec playerctl play";
          "XF86AudioPause" = "exec playerctl pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
          "${modifier}+Shift+1" = "move container to workspace number 1; workspace 1";
          "${modifier}+Shift+2" = "move container to workspace number 2; workspace 2";
          "${modifier}+Shift+3" = "move container to workspace number 3; workspace 3";
          "${modifier}+Shift+4" = "move container to workspace number 4; workspace 4";
          "${modifier}+Shift+5" = "move container to workspace number 5; workspace 5";
          "${modifier}+Shift+6" = "move container to workspace number 6; workspace 6";
          "${modifier}+Shift+7" = "move container to workspace number 7; workspace 7";
          "${modifier}+Shift+8" = "move container to workspace number 8; workspace 8";
          "${modifier}+Shift+Left" = "move workspace to output left";
          "${modifier}+Shift+Right" = "move workspace to output right";
        };

        modes = {
          resize = {
            h = "resize shrink width 5 px or 5 ppt";
            j = "resize grow height 5 px or 5 ppt";
            k = "resize shrink height 5 px or 5 ppt";
            l = "resize grow width 5 px or 5 ppt";
            Left = "resize shrink width 10 px or 10 ppt";
            Down = "resize grow height 10 px or 10 ppt";
            Up = "resize shrink height 10 px or 10 ppt";
            Right = "resize grow width 10 px or 10 ppt";
            Return = "mode \"default\"";
            Escape = "mode \"default\"";
          };
        };

        modifier = "${modifier}";

        startup = [
          {
            command = "${pkgs.pulseaudio}/bin/pulseaudio";
            notification = false;
          }
          {
            command = "${pkgs.xautolock}/bin/xautolock -detectsleep -time 5 -locker 'betterlockscreen --lock' -notify 10 -notifier '${pkgs.libnotify}/bin/notify-send -t 10000 \" Screen lock coming \"'";
            notification = false;
          }
          {
            command = "${pkgs.xorg.xset}/bin/xset -dpms s off";
            notification = false;
          }
          {
            command = "${pkgs.hsetroot}/bin/hsetroot -solid \"${solarizedColors.base02}\"";
            notification = false;
          }
          {
            command = "nm-applet";
            notification = false;
          }
          # {
          # command = "${pkgs.conky}/bin/conky -c .config/conky_khal";
          # notification = false;
          # }
          # {
          # command = "${pkgs.conky}/bin/conky -c .config/conky_shortcuts";
          # notification = false;
          # }
          {
            command = "xinput set-prop 13 --type=int --format=8 276 1";
            notification = false;
          }
          {
            command = "backintime-qt";
            notification = false;
          }
          {
            command = "${pkgs.autorandr}/bin/autorandr -c";
            notification = false;
          }
          # {
          # command = "${pkgs.i3wsr}/bin/i3wsr";
          # }
        ];

        window.titlebar = false;

        # See https://i3wm.org/docs/userguide.html#assign_workspace
        assigns = {
          "7: teams" = [{ class = "Microsoft Teams - Preview"; }];
          "8: chats" = [{ class = "Element"; } { class = "Mattermost"; }];
        };
      };

      extraConfig = ''
        # Set shut down, restart and locking features
        bindsym ${modifier}+q mode "$mode_system"
        set $mode_system (l)ock, (e)xit, switch_(u)ser, (s)uspend, (h)ibernate, (r)eboot, (Shift+s)hutdown, (d)isable screenlock
        mode "$mode_system" {
        bindsym l exec --no-startup-id xautolock -locknow, mode "default"
        bindsym s exec --no-startup-id ${i3exit}/bin/i3exit suspend, mode "default"
        bindsym u exec --no-startup-id ${i3exit}/bin/i3exit switch_user, mode "default"
        bindsym e exec --no-startup-id ${i3exit}/bin/i3exit logout, mode "default"
        bindsym h exec --no-startup-id ${i3exit}/bin/i3exit hibernate, mode "default"
        bindsym r exec --no-startup-id ${i3exit}/bin/i3exit reboot, mode "default"
        bindsym d exec --no-startup-id ${pkgs.xautolock}/bin/xautolock -disable, mode "default"
        bindsym Shift+s exec --no-startup-id ${i3exit}/bin/i3exit shutdown, mode "default"

        # exit system mode: "Enter" or "Escape"
        bindsym Return mode "default"
        bindsym Escape mode "default"
        }

        workspace 1 output DP2
        workspace 2 output DP2
        workspace 3 output DP2
        workspace 4 output DP2
        workspace 5 output DP2
        workspace 6 output DP2
        workspace 7 output eDP1
        workspace 8 output eDP1
      '';
    };

    home.file.".config/i3status-rust/config.toml".text = ''
      [theme]
      file = "/home/jtraue/.i3status-color.toml"
      [icons]
      name = "awesome5"

      [[block]]
      block = "custom"
      on_click = "${onboard-keyboard-control}/bin/onboard-keyboard-control"
      command = "if test -f /tmp/onboard.pid; then echo 'hide onboard keyboard'; else echo 'show onboard keyboard'; fi"
      interval = 3

      [[block]]
      block = "custom"
      on_click = "${theme-switch}/bin/theme-switch"
      command = "cat ~/.color"
      interval = 3

      [[block]]
      block = "watson"
      show_time = true

      [[block]]
      block = "taskwarrior"
      interval = 30
      format = "{count} open tasks ({filter_name})"
      format_singular = "{count} open task ({filter_name})"
      format_everything_done = "nothing to do!"
      warning_threshold = 1
      critical_threshold = 5
      [[block.filters]]
      name = "week"
      filter = "+PENDING +WEEK"

      [[block]]
      block = "disk_space"
      path = "/"
      alias = "root:"
      info_type = "available"
      unit = "GB"
      interval = 20
      warning = 20.0
      alert = 10.0

      [[block]]
      block = "memory"
      display_type = "memory"
      format_mem = "mem: {mem_used_percents}"
      format_swap = "{swap_used_percents}"

      [[block]]
      block = "cpu"
      interval = 1
      format = "{utilization}"

      [[block]]
      block = "networkmanager"
      on_click = "kitty nmtui"
      interface_name_exclude = ["br\\-[0-9a-f]{12}", "docker\\d+"]
      interface_name_include = []
      ap_format = "{ssid^10}"


      [[block]]
      block = "battery"
      interval = 10
      format = "{percentage} {time}"

      [[block]]
      block = "sound"

      [[block]]
      block = "time"
      interval = 60
      format = "%d.%m.%y %R"
    '';

  };
}
