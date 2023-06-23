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
      tmux
      unzip
      usbutils
      wget
      whois
      zip
    ];

    i18n.defaultLocale = "en_US.UTF-8";

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "jtraue" ];
    };

    nixpkgs = {
      inherit overlays;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    programs = {
      vim.defaultEditor = true;
      zsh.enable = true;
    };

    services = {
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

