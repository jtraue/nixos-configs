{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.desktop.sway;
in
{

  options.home-modules.desktop.sway.enable = lib.mkEnableOption "Enables sway.";

  config = lib.mkIf cfg.enable {
    services.kanshi = {
      enable = true;
    };
    wayland.windowManager.sway = {
      enable = true;
      package = null;
      systemd.enable = true;
      config = {
        modifier = "Mod4";
        terminal = "${pkgs.foot}/bin/foot";
        # startup = [
        #   # Launch Firefox on start
        #   { command = "firefox"; }
        # ];
      };
    };

  };
}
