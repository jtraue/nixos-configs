{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.common.timetracking;
in
{

  options.home-modules.common.timetracking.enable = lib.mkEnableOption "Enables timetracking with watson and taskwarrior.";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs;[
      watson-notify
      taskwarrior-tui
    ];

    programs.taskwarrior = {
      enable = true;
      dataLocation = "~/.task";
      colorTheme = "solarized-dark-256";
      extraConfig = ''
        weekstart = monday
      '';
    };

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
        ExecStart = "${pkgs.watson-notify}/bin/watson-notify";
      };
    };
    systemd.user.timers.watson-notify = {
      Install = { WantedBy = [ "timers.target" ]; };
      Timer = { OnBootSec = "5min"; OnUnitActiveSec = "5min"; };
    };

    # home.file."${config.programs.taskwarrior.dataLocation}/hooks/on-modify.watson.sh".text = ''
    # '';

    programs.i3status-rust.bars.top.blocks = lib.mkIf config.programs.i3status-rust.enable [
      {
        block = "watson";
        show_time = true;
      }
      {
        block = "taskwarrior";
        interval = 30;
        format = "$count open tasks ($filter_name)";
        format_singular = "$count open task ($filter_name)";
        format_everything_done = "nothing to do!";
        warning_threshold = 1;
        critical_threshold = 5;
        filters = [
          {
            name = "week";
            filter = "+PENDING +WEEK";
          }
        ];
      }
    ];
  };
}
