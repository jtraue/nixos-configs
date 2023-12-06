{ pkgs, ... }:
{

  imports = [
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixos-modules = {
    common.enable = true;
    desktop.enable = true;
    desktop.x11.enable = false;
    desktop.sway.enable = true;
    yubikey.enable = false;
  };

  # pipewire complains about missing xdg-portals (https://www.reddit.com/r/NixOS/comments/y877ou/pipewire_not_working_requires_xdgportals/)
  xdg.portal.enable = true;

  # -- network
  # Note for future me: nmtui can be used for network config on terminal
  networking = {
    hostName = "vm";
  };

  system.stateVersion = "22.05";
}
