{ config, lib, pkgs, ... }:
let
  cfg = config.nixos-modules.desktop.gnome;
in
{
  options.nixos-modules.desktop.gnome.enable = lib.mkEnableOption "Enable gnome";

  config = lib.mkIf cfg.enable {
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    security.polkit.enable = true;


    # workaround for autologin (see https://nixos.wiki/wiki/GNOME)
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    services = {
      libinput = {
        enable = true;
      };
      displayManager = {
        gdm.enable = true;
        autoLogin =
          {
            enable = true;
            user = "${config.nixos-modules.common.user}";
          };
      };
      desktopManager.gnome.enable = true;
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "intl";
          options = "caps:escape";
        };
      };
    };
    environment.systemPackages = [
      pkgs.gnome-tweaks
      pkgs.gnomeExtensions.appindicator
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

    services.udev.packages = [ pkgs.gnome-settings-daemon ];

  };
}
