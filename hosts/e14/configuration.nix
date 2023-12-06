{ inputs, ... }:
{

  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel
  ];

  networking.hostName = "e14";

  nixos-modules.common.enable = true;
  nixos-modules.desktop.enable = true;
  nixos-modules.desktop.x11.enable = true;
  nixos-modules.desktop.sway.enable = false;
  nixos-modules.work.enable = true;
  nixos-modules.yubikey.enable = true;

  boot.extraModprobeConfig = "options kvm_intel nested=1";
  boot.kernelParams = [ "intel_iommu=off" ];

  system.stateVersion = "22.05";
}
