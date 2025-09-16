{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.desktop.gnome;
in
{

  options.home-modules.desktop.gnome.enable = lib.mkEnableOption "Enables gnome.";

  config = lib.mkIf cfg.enable {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            blur-my-shell.extensionUuid
            gsconnect.extensionUuid
          ];
        };
        "org/gnome/desktop/input-sources" = {
          xkb-options = [ "ctrl:nocaps" ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>Return";
          name = "terminal";
          command = "kgx -- tmux";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Shift><Control>p";
          name = "1password";
          command = "1password --quick-access";
        };
      };
    };
  };
}
