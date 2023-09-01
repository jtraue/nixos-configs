{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.common.watson;
  inherit (pkgs) watson-notify;
in
{

  options.home-modules.common.watson.enable = lib.mkEnableOption "Enables watson.";

  config = lib.mkIf cfg.enable {

    home.packages = [
      watson-notify
    ];

    programs.watson = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # i3status-rust watson block does not handle "watson stop" correctly,
        # and the suggestion is to automatically stop when starting something new
        # https://github.com/greshake/i3status-rust/issues/1305
        options = {
          stop_on_start = true;
          week_start = "monday";
          log_current = true;
        };
      };
    };

    systemd.user.services.watson-notify = {
      Service = {
        Type = "oneshot";
        ExecStart = "${watson-notify}/bin/watson-notify";
      };
    };
    systemd.user.timers.watson-notify = {
      Install = { WantedBy = [ "timers.target" ]; };
      Timer = { OnBootSec = "5min"; OnUnitActiveSec = "5min"; };
    };
  };

}
