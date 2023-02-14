{ config, lib, pkgs, overlays, ... }:
let
  cfg = config.nixos-modules.common;
in
{
  options.nixos-modules.common.enable = lib.mkEnableOption "Enable common options.";

  config = lib.mkIf cfg.enable {

    boot = {
      cleanTmpDir = true;
      loader.systemd-boot.enable = true;
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

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs = {
      inherit overlays;
      config = {
        allowUnfree = true;
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
      users.jtraue = {
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
      };
    };
  };
}
