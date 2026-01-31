{ config, lib, pkgs, ... }:
let
  cfg = config.my.common;
in
{
  options.my.common = {
    enable = lib.mkEnableOption "common NixOS settings (boot, networking, nix, users)";
    user = lib.mkOption {
      type = lib.types.str;
      default = "jtraue";
    };
  };

  config = lib.mkIf cfg.enable {

    boot = {
      tmp.cleanOnBoot = true;
      loader.systemd-boot.enable = lib.mkDefault true;
      loader.systemd-boot.configurationLimit = 10;
      loader.efi.canTouchEfiVariables = true;
    };

    console.font = "Lat2-Terminus16";

    documentation = {
      enable = true;
      dev.enable = true;
    };

    environment.systemPackages = with pkgs; [
      ack
      curl
      dnsutils
      exfat
      file
      git
      man-pages
      man-pages-posix
      nmap
      pciutils
      powertop
      tmux
      unzip
      usbutils
      wget
      whois
      zip
    ];

    hardware = {
      trackpoint = {
        emulateWheel = true;
        fakeButtons = true;
      };
    };

    i18n.defaultLocale = "en_US.UTF-8";

    networking.networkmanager.enable = true;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" cfg.user ];
      substituters = [
        "https://cache.nixos.org"
        "https://jtraue.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "jtraue.cachix.org-1:su05S1o/u2/LDKEIz6Y6wGNkRriF95LeD5T5pYJJOso="
      ];
    };

    nix.gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 90d";
    };

    nix.optimise.automatic = true;

    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    powerManagement.enable = true;

    programs = {
      command-not-found.enable = true;
      vim = {
        enable = true;
        defaultEditor = true;
      };
      zsh.enable = true;
    };

    services = {
      acpid.enable = true;
      fwupd.enable = true;
      cron.enable = true;
    };

    time.timeZone = "Europe/Berlin";

    users = {
      extraGroups.plugdev = { gid = 500; };
      users."${cfg.user}" = {
        createHome = true;
        isNormalUser = true;
        extraGroups =
          [
            "dialout"
            "docker"
            "libvirtd"
            "lp"
            "scanner"
            "sound"
            "tty"
            "wheel"
          ];
        shell = "${pkgs.zsh}/bin/zsh";
      };
    };

  };
}
