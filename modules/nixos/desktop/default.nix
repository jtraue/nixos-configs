{ config, lib, pkgs, ... }:
let
  cfg = config.nixos-modules.desktop;
in
{
  imports = [
    ./autorandr.nix
    ./x11.nix
  ];

  options.nixos-modules.desktop.enable = lib.mkEnableOption "Enable desktop environment.";

  config = lib.mkIf cfg.enable {

    nixos-modules.desktop.autorandr.enable = true;
    nixos-modules.desktop.x11.enable = true;
    hardware = {
      opengl = {
        enable = true;
        driSupport32Bit = true;
      };
    };

    networking.networkmanager.enable = true;

    programs = {
      command-not-found.enable = true;
      dconf.enable = true; # Gtk3 apps seem to require dconf :/
      seahorse.enable = true; # gnome keyring manager
      evolution = {
        enable = true;
        plugins = [ pkgs.evolution-ews ];
      };
      light.enable = true; # backlight
    };

    security.pam.services.lightdm.enableGnomeKeyring = true;

    services = {
      gnome.gnome-keyring.enable = true;
      dbus.packages = with pkgs; [ dconf ];
    };
    systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];

    users.users.jtraue.extraGroups = [
      "audio"
      "plugdev"
      "networkmanager"
      "wireshark"
      "video"
    ];

    services.udisks2.enable = true; # for udiskie

    # -- fonts
    fonts = {
      enableDefaultFonts = true;
      enableGhostscriptFonts = true;
      fontDir.enable = true;
      # fontconfig = {
      # defaultFonts = { monospace = [ "Fira Code Light" ]; };
      # };

    };
    nixpkgs.config.input-fonts.acceptLicense = true;

    # -- power
    powerManagement.enable = true;
    services.acpid.enable = true;

    # -- scanner
    hardware.sane.enable = true;

    # -- sound
    # rtkit is optional but recommended
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    services.pipewire = {
      config.pipewire = {
        "context.properties" = {
          #"link.max-buffers" = 64;
          "link.max-buffers" = 16; # version < 3 clients can't handle more than this
          "log.level" = 2; # https://docs.pipewire.org/page_daemon.html
          #"default.clock.rate" = 48000;
          #"default.clock.quantum" = 1024;
          #"default.clock.min-quantum" = 32;
          #"default.clock.max-quantum" = 8192;
        };
      };
    };

    # -- printing
    # slp and mdns for printer
    networking.firewall.allowedUDPPorts = [ 427 5353 ];
    services.printing.enable = true;
    # (https://nixos.wiki/wiki/Printing)
    # Strange install - select driver below, then
    # - remove existing printers (via http://localhost:631)
    # - sudo systemctl restart cups.service
    # - sudo systemctl stop firewall.service
    # - nix-shell -p hplipWithPlugin --run 'sudo hp-setup -i'
    #   - select net printer  - it should be auto discovered
    # - go to cups website and modify printer (duplex, a4, 2 sided)
    services.printing.drivers = [ pkgs.hplipWithPlugin ];
  };

}
