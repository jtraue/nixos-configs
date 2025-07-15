{ config, lib, pkgs, ... }:
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
        autoLogin =
          {
            enable = true;
            user = "${config.nixos-modules.common.user}";
          };
      };
      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        xkb = {
          layout = "us";
          variant = "intl";
          options = "caps:escape";
        };
      };
    };
    environment.systemPackages = [
      pkgs.gnome-tweaks
    ] ++
    (with
    pkgs.gnomeExtensions; [
      battery-time
      tray-icons-reloaded
      tailscale-status
      caffeine
      user-themes
      move-clock
      vitals
      top-bar-organizer
    ]);
  };
}
