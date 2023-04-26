{ config, lib, ... }:
let
  cfg = config.nixos-modules.desktop.x11;
in
{
  options.nixos-modules.desktop.x11.enable = lib.mkEnableOption "Enable x11";

  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        libinput = {
          enable = true;
        };
        enable = true;
        displayManager = {
          defaultSession = "none+i3";
          autoLogin =
            {
              enable = true;
              user = "jtraue";
            };
        };
        layout = "us";
        xkbVariant = "intl";
        xkbOptions = "caps:escape";
        windowManager.i3 = {
          enable = true;
        };
      };
    };
  };
}
