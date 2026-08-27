{ config, lib, inputs, osConfig ? null, ... }:
let
  cfg = config.my.desktop.niri;

  # `osConfig` is only set (see home-manager's nixos/common.nix specialArgs)
  # when this module runs embedded via the NixOS home-manager module. In
  # that case, default to following the NixOS-level my.desktop.niri.enable
  # so enabling the session at the system level (programs.niri.enable) also
  # brings along config.kdl and noctalia here, instead of silently leaving
  # niri running with its built-in fallback config and no shell.
  osLevelEnable = osConfig != null && (osConfig.my.desktop.niri.enable or false);
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.my.desktop.niri.enable = lib.mkOption {
    type = lib.types.bool;
    default = osLevelEnable;
    defaultText = lib.literalExpression "osConfig.my.desktop.niri.enable or false";
    description = "niri session config (config.kdl) and the noctalia shell.";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = osConfig == null || osLevelEnable;
        message = ''
          `my.desktop.niri.enable` is set in home-manager but not at the
          NixOS level (`my.desktop.niri.enable` in configuration.nix) - the
          niri session itself won't be installed. Enable it there too.
        '';
      }
    ];

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
