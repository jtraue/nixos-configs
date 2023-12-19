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
      wsr
    ];

    programs.taskwarrior = {
      enable = true;
      colorTheme = "solarized-dark-256";
      extraConfig = ''
        weekstart = monday
      '';
      dataLocation = "/home/jtraue/cloud/cyberus/storage/task";
    };

    home.sessionVariables = {
      WATSON_DIR = "/home/jtraue/cloud/cyberus/storage/watson";
    };
    # keep in mind to copy watson s config file to the cloud storage
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

    home.file."${config.programs.taskwarrior.dataLocation}/hooks/on-modify-watson.py" = {
      text = builtins.readFile pkgs.watson-timewarrior-hook;
      executable = true;
    };

    programs.i3status-rust.bars.top.blocks = lib.mkIf config.programs.i3status-rust.enable [
      {
        block = "watson";
        show_time = true;
        state_path = "~/cloud/cyberus/storage/watson/state";
        click = [
          {
            button = "right";
            cmd = "${pkgs.watson-notify}/bin/watson-notify $(echo -e '--snooze\n--activate' | dmenu)";
          }
          {
            button = "left";
            cmd = "${pkgs.watson}/bin/watson $(echo -e 'stop\nrestart' | dmenu)";
          }
        ];
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
        click = [
          {
            button = "left";
            cmd = "${pkgs.kitty}/bin/kitty ${pkgs.taskwarrior-tui}/bin/taskwarrior-tui";
          }
        ];
      }
    ];
  };
}
