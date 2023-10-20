{ pkgs, homeManagerModules, pkgs-unstable, ... }:
let
  inherit (pkgs-unstable) teams;
in
{
  imports = builtins.attrValues homeManagerModules;

  home-modules.common.enable = true;
  home-modules.desktop.enable = true;
  home-modules.dev.enable = true;
  home-modules.usbbackup.enable = true;
  home-modules.common.timetracking.enable = true;

  services.blueman-applet.enable = true;

  programs.git = {
    userEmail = "jana.traue@cyberus-technology.de";
  };

  home.packages = with pkgs; [
    drawio
    qemu-ipxe
    sotest-to-ipxe
    amt-control
    maestral-gui
    teams
    gita
  ];

  xsession.windowManager.i3.config = {
    startup = [
      {
        command = "${teams}/bin/teams";
        notification = false;
      }
      {
        command = "${pkgs.signal-desktop}/bin/signal-desktop --use-tray-icon --start-in-tray";
        notification = false;
      }
      {
        # Unlock gnome-keyrings (see <https://wiki.archlinux.org/title/GNOME/Keyring#Launching_gnome-keyring-daemon_outside_desktop_environments_(KDE,_GNOME,_XFCE,_...)>)
        command = "dbus-update-activation-environment --all";
        notification = false;
      }
    ];
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "build01" = {
        hostname = "build01";
        user = "jana";
      };
      "olympus-mons" = {
        hostname = "olympus-mons";
        user = "jana";
      };
      "mount-koma" = {
        hostname = "mount-koma";
        user = "jana";
      };
      "mount-doom" = {
        hostname = "mount-doom";
        user = "jana";
      };
      "mount-hood" = {
        hostname = "mount-hood";
        port = 2222;
      };
      "testbox_home" = {
        host = "10.0.0.10";
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
      };
      "thinkstation" = {
        host = "10.0.0.11";
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
      };
      "qemu" = {
        hostname = "127.0.0.1";
        port = 2221;
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
      };
    };
  };
}
