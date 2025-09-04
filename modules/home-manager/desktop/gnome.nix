{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.desktop.gnome;
in
{

  options.home-modules.desktop.gnome.enable = lib.mkEnableOption "Enables gnome.";

  config = lib.mkIf cfg.enable {
    dconf = {
      enable = true;
      settings."org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          gsconnect.extensionUuid
        ];
      };
    };
  };
}
