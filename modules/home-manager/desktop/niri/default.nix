{ config, lib, inputs, ... }:
let
  cfg = config.my.desktop.niri;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.my.desktop.niri.enable = lib.mkEnableOption "niri session config (config.kdl) and the noctalia shell";

  config = lib.mkIf cfg.enable {
    xdg.configFile."niri/config.kdl".source = ./config.kdl;

    programs.noctalia = {
      enable = true;
      settings = {
        # This may also be a string or path to a .toml file.
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
          community_palette = "Oxocarbon";
          wallpaper_scheme = "m3-content";
          templates = {
            builtin_ids = [ "alacritty" "btop" "niri" "qt" "gtk3" "gtk4" ];
            community_ids = [ "fuzzel" ];
          };
        };

        wallpaper = {
          enabled = true;
        };

        idle = {
          behavior_order = [ "lock" "screen-off" "lock-and-suspend" ];
          behavior = {
            lock = {
              action = "lock";
              enabled = true;
              timeout = 600.0;
            };
            "screen-off" = {
              action = "screen_off";
              enabled = true;
              timeout = 660.0;
            };
            "lock-and-suspend" = {
              action = "lock_and_suspend";
              enabled = false;
              timeout = 900.0;
            };
          };
        };

        shell = {
          app_icon_colorize = true;
        };

        bar.default = {
          center = [ ];
          end = [
            "media"
            "tray"
            "notifications"
            "clipboard"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "clock"
            "control-center"
            "session"
          ];
        };

        dock = {
          enabled = true;
          reserve_space = false;
          smart_auto_hide = true;
        };

        plugins.enabled = [ "raycursive/niri-displays" "noctalia/wallhaven" ];
      };
    };
  };
}
