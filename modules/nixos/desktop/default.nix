{ config, lib, pkgs, ... }:
let
  cfg = config.nixos-modules.desktop;
in
{
  imports = [
    ./gnome.nix
  ];

  options.nixos-modules.desktop.enable = lib.mkEnableOption "Enable desktop environment.";

  config = lib.mkIf cfg.enable {

    nixos-modules.desktop.gnome.enable = lib.mkDefault true;

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    programs = {
      evolution = {
        enable = true;
        plugins = [ pkgs.evolution-ews ];
      };
      light.enable = true; # backlight
    };

    services = {
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

    # Enable the unfree 1Password packages
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "1password-gui"
      "1password"
    ];
    # Alternatively, you could also just allow all unfree packages
    # nixpkgs.config.allowUnfree = true;

    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ "jtraue" ];
    };

    # -- fonts
    fonts = {
      enableDefaultPackages = true;
      enableGhostscriptFonts = true;
      fontDir.enable = true;
      # fontconfig = {
      # defaultFonts = { monospace = [ "Fira Code Light" ]; };
      # };
      packages = builtins.filter lib.isDerivation (builtins.attrValues pkgs.nerd-fonts);

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

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;

  };

}
