{ config, pkgs, nixos-hardware, nixosModules, ... }:
{
  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
  ]
  ++ builtins.attrValues nixosModules;

  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose"; # for tailscale

  nixos-modules.common.enable = true;
  nixos-modules.desktop.enable = true;
  nixos-modules.yubikey.enable = true;

  networking = {
    hostName = "x13";
  };

  hardware.opengl = {
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
    ];
  };
  environment.systemPackages = with pkgs; [
    steam
  ];

  system.stateVersion = "21.05";
}
