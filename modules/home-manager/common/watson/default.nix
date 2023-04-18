{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.common.watson;
  inherit (pkgs) watson-notify;
in
{

  options.home-modules.common.watson.enable = lib.mkEnableOption "Enables watson.";

  config = lib.mkIf cfg.enable {

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

    systemd.user.services = {
      watson-notify = {
        Unit = {
          Description = "Watson check";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart =
            let
              script = pkgs.writeScript "watson-notify" ''
                echo "watson check is running"
                ${watson-notify}/bin/watson-notify
              '';
            in
            "${pkgs.bash}/bin/bash ${script}";
        };
      };
    };
  };

}
