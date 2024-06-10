{ config, lib, ... }:
let
  cfg = config.nixos-modules.desktop.x11;
in
{
  options.nixos-modules.desktop.x11.enable = lib.mkEnableOption "Enable x11";

  config = lib.mkIf cfg.enable {
    services = {
      libinput = {
        enable = true;
      };
      displayManager = {
        defaultSession = "none+i3";
        autoLogin =
          {
            enable = true;
            user = "${config.nixos-modules.common.user}";
          };
      };
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "intl";
          options = "caps:escape";
        };
        windowManager.i3 = {
          enable = true;
        };
      };
    };
  };
}
