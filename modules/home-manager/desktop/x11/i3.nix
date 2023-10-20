{ config, lib, pkgs, ... }:


# For unicode symbols go to https://unicode-table.com
# Search for your symbol
#   example: battery - number U+1F50B
# Insert in vim via: Ctrl+v U1f50b (+space)
let
  cfg = config.home-modules.desktop.i3;
  inherit (config.colorscheme) colors;
  inherit (pkgs.stdenv) mkDerivation;

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
            frame_color = "#${colors.base00}";
            frame_width = 3;
            fonts = [ "pango:Cantarell 12" ];
          };

          urgency_low = {
            background = "#${colors.base00}";
            foreground = "#${colors.base05}";
            timeout = 5;
          };
          urgency_normal = {
            background = "#${colors.base00}";
            foreground = "#${colors.base09}";
            frame_color = "#${colors.base09}";
            timeout = 10;
          };
          urgency_critical = {
            background = "#${colors.base00}";
            foreground = "#${colors.base08}";
            frame_color = "#${colors.base08}";
            timeout = 20;
          };
        };
    };

    home.packages = with pkgs;[
      i3
      xautolock
      siji
      font-awesome
      font-awesome_5
    ];

    services.screen-locker = {
      enable = true;
      lockCmd = "${pkgs.betterlockscreen}/bin/betterlockscreen --lock";
      inactiveInterval = 5;
      xautolock = {
        extraOptions = [
          "-notify 20"
          "-notifier '${pkgs.libnotify}/bin/notify-send -t 10000 \" Screen lock coming \"'"
        ];
      };
    };

    xsession.enable = true;
    xsession.windowManager.i3 = {
      enable = true;

      config = {
        bars = [
          {
            position = "top";
            colors = {
              background = "#${colors.base00}";
              statusline = "#${colors.base04}";
              separator = "#${colors.base01}";
              activeWorkspace = {
                background = "#${colors.base03}";
                border = "#${colors.base05}";
                text = "#${colors.base00}";
              };
              bindingMode = {
                background = "#${colors.base0A}";
                border = "#${colors.base00}";
                text = "#${colors.base00}";
              };
              focusedWorkspace = {
                background = "#${colors.base0D}";
                border = "#${colors.base05}";
                text = "#${colors.base00}";
              };
              inactiveWorkspace = {
                background = "#${colors.base01}";
                border = "#${colors.base03}";
                text = "#${colors.base05}";
              };
              urgentWorkspace = {
                background = "#${colors.base08}";
                border = "#${colors.base08}";
                text = "#${colors.base00}";
              };
            };
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
            fonts = {
              names = [ "FontAwesome" ];
              size = 10.0;
            };
          }
        ];

        colors = {
          focused = {
            border = "#${colors.base05}";
            background = "#${colors.base0D}";
            text = "#${colors.base00}";
            indicator = "#${colors.base0D}";
            childBorder = "#${colors.base0C}";
          };
          unfocused = {
            border = "#${colors.base01}";
            background = "#${colors.base08}";
            text = "#${colors.base05}";
            indicator = "#${colors.base01}";
            childBorder = "#${colors.base01}";
          };
          focusedInactive = {
            border = "#${colors.base01}";
            background = "#${colors.base01}";
            text = "#${colors.base05}";
            indicator = "#${colors.base03}";
            childBorder = "#${colors.base01}";
          };
          urgent = {
            border = "#${colors.base08}";
            background = "#${colors.base08}";
            text = "#${colors.base00}";
            indicator = "#${colors.base08}";
            childBorder = "#${colors.base08}";
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
          "${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -modi drun#run#ssh -combi-modi drun#run -show combi -show-icons -display-combi run";
          "${modifier}+x" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -modi window -show window -auto-select";
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
            command = "${pkgs.xorg.xset}/bin/xset -dpms s off";
            notification = false;
          }
          {
            command = "${pkgs.hsetroot}/bin/hsetroot -solid \"#${colors.base00}\"";
            notification = false;
          }
          {
            command = "nm-applet";
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
          {
            command = "${pkgs._1password-gui}/bin/1password --silent";
            notification = false;
          }
        ];

        window.titlebar = false;

        # See https://i3wm.org/docs/userguide.html#assign_workspace
        # Use `xprop` on the same workspace for information.
        assigns = {
          "7: teams" = [{ class = "teams-for-linux"; }];
        };
      };

      extraConfig = ''
        # Set shut down, restart and locking features
        bindsym ${modifier}+q mode "$mode_system"
        set $mode_system (l)ock, (e)xit, (s)uspend, (h)ibernate, (r)eboot, (Shift+s)hutdown, (d)isable screenlock, (e)nable screenlock
        mode "$mode_system" {
        bindsym s exec --no-startup-id ${i3exit}/bin/i3exit suspend, mode "default"
        bindsym e exec --no-startup-id ${i3exit}/bin/i3exit logout, mode "default"
        bindsym h exec --no-startup-id ${i3exit}/bin/i3exit hibernate, mode "default"
        bindsym r exec --no-startup-id ${i3exit}/bin/i3exit reboot, mode "default"
        bindsym l exec --no-startup-id ${pkgs.xautolock}/bin/xautolock -locknow, mode "default"
        bindsym d exec --no-startup-id ${pkgs.xautolock}/bin/xautolock -disable, mode "default"
        bindsym d exec --no-startup-id ${pkgs.xautolock}/bin/xautolock -enable, mode "default"
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

    programs.i3status-rust = {
      enable = true;
      bars = {
        top = {
          blocks = [
            {
              block = "disk_space";
              path = "/";
              format = "root: $available/$total";
              alert_unit = "GB";
              interval = 20;
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "memory";
              format = "$icon $mem_used/$mem_total ($mem_used_percents)";
            }
            {
              block = "cpu";
              interval = 1;
              format = "$icon $utilization";
            }
            {
              block = "net";
              format = " $icon {$signal_strength $ssid $frequency|Wired connection} via $device ";
            }
            {
              block = "battery";
              interval = 10;
              format = "$percentage $time";
            }
            {
              block = "sound";
            }
            {
              block = "time";
              format = "$timestamp.datetime(f:'%d.%m.%y %R')";
              interval = 60;
            }
          ];
          icons = "awesome6";
          theme = "gruvbox-dark";
        };
      };
    };
  };
}
