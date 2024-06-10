{ pkgs, inputs, nixosModules, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
    nixosModules.common
    nixosModules.desktop
    nixosModules.yubikey
  ];

  programs.adb.enable = true;
  users.users.jtraue.extraGroups = [ "adbusers" ];

  virtualisation.docker.enable = true;



  # Let's see whether this fixes random audio outages
  # as suggested in https://discourse.nixos.org/t/weird-audio-behavior-pipewire-pulseaudio-not-working-sometimes/24124/2
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services = {
    tailscale.enable = true;
    libinput.mouse.accelSpeed = "0.0";
  };
  networking.firewall.checkReversePath = "loose"; # for tailscale

  nixos-modules.common.enable = true;
  nixos-modules.desktop.enable = true;
  nixos-modules.yubikey.enable = true;

  networking = {
    hostName = "x13";
  };

  hardware = {
    trackpoint.device = "TPPS/2 ALPS TrackPoint";
    opengl = {
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    steam
    calibre
  ];

  system.stateVersion = "21.05";
}
