{ config, pkgs, inputs, nixosModules, lib, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
    nixosModules.common
    nixosModules.desktop
  ];

  services.fprintd.enable = true;

  # workaround for autologin (see https://nixos.wiki/wiki/GNOME)
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.adb.enable = true;
  users.users.jtraue.extraGroups = [
    "adbusers"
    "libvirtd"
  ];

  virtualisation.docker.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;


  # Let's see whether this fixes random audio outages
  # as suggested in https://discourse.nixos.org/t/weird-audio-behavior-pipewire-pulseaudio-not-working-sometimes/24124/2
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.libinput.mouse.accelSpeed = "0.0";
  services = {
    tailscale.enable = true;
    printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin ];
  };
  networking.firewall.checkReversePath = "loose"; # for tailscale

  nixos-modules.common.enable = true;
  nixos-modules.desktop.enable = true;

  networking = {
    hostName = "x13";
  };

  hardware = {
    trackpoint.device = "TPPS/2 ALPS TrackPoint";
    graphics = {
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
      ];
    };
  };

  # Automatic screen rotation
  hardware.sensor.iio.enable = true;

  environment.systemPackages = with pkgs; [
    steam
    calibre
    gnome-boxes
  ] ++ (with
    pkgs.gnomeExtensions; [
    touch-x
  ]);

  powerManagement = {
    powertop.enable = true;
  };
  services.auto-cpufreq = {
    enable = false;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  system.stateVersion = "21.05";
}
