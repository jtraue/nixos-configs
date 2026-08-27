{ config, lib, pkgs, ... }:
let
  cfg = config.my.desktop.niri;
in
{
  options.my.desktop.niri.enable = lib.mkEnableOption "niri session alongside GNOME (picked at the GDM greeter)";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      # niri session: terminal (Mod+T) and app launcher (Mod+D)
      alacritty
      fuzzel
      # niri session: multi-monitor setup (Super+Alt+M)
      wdisplays
      wl-mirror
    ];
  };
}
