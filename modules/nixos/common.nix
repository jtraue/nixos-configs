{ config, lib, pkgs, overlays, ... }:
let
  cfg = config.nixos-modules.common;
in
{
  options.nixos-modules.common = {
    enable = lib.mkEnableOption "Enable common options.";
    user = lib.mkOption {
      type = lib.types.str;
      default = "jtraue";
    };
  };

  config = lib.mkIf cfg.enable {

    boot = {
      tmp.cleanOnBoot = true;
      loader.systemd-boot.enable = lib.mkDefault true;
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
    };

    nixpkgs = {
      inherit overlays;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    powerManagement.enable = true;

    programs = {
      command-not-found.enable = true;
      vim.defaultEditor = true;
      zsh.enable = true;
    };

    services = {
      acpid.enable = true;
      fwupd.enable = true;
      cron.enable = true;
    };

    system.autoUpgrade.enable = true;

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
        initialPassword = "1234";
      };
    };

  };
}

