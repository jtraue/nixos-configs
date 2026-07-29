{ config, lib, pkgs, ... }:
let
  cfg = config.my.desktop.gnome;
in
{
  options.my.desktop.gnome.enable = lib.mkEnableOption "Enable gnome";

  config = lib.mkIf cfg.enable {
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    security.polkit.enable = true;


    # workaround for autologin (see https://nixos.wiki/wiki/GNOME)
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    programs.firefox.enable = true;

    services = {
      libinput = {
        enable = true;
      };
      displayManager = {
        gdm.enable = true;
        autoLogin =
          {
            enable = true;
            user = "${config.my.common.user}";
          };
      };
      desktopManager.gnome.enable = true;
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "intl";
        };
      };
      gnome.gnome-browser-connector.enable = true;
    };
    environment.systemPackages = [
      pkgs.gnome-tweaks
      pkgs.gnomeExtensions.appindicator
      pkgs.nemo
    ] ++
    (with
    pkgs.gnomeExtensions; [
      auto-move-windows
      battery-time
      caffeine
      emoji-copy
      move-clock
      space-bar
      tailscale-status
      top-bar-organizer
      tray-icons-reloaded
      user-themes
      vitals
    ]);

    environment.gnome.excludePackages = with pkgs; [
      baobab
      epiphany
      geary
      gnome-characters
      gnome-connections
      gnome-contacts
      gnome-software
      orca
      simple-scan
      yelp
    ];

    services.udev.packages = [ pkgs.gnome-settings-daemon ];

  };
}
