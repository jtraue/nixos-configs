{ nixos-hardware, pkgs, ... }:
{

  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel
  ];

  services.opensnitch = {
    enable = true;
  };

  services.onedrive.enable = true;

  nixos-modules.common.enable = true;
  nixos-modules.desktop.enable = true;
  nixos-modules.desktop.x11.enable = true;
  nixos-modules.desktop.sway.enable = false;
  nixos-modules.notebook.enable = true;
  nixos-modules.work.enable = true;
  nixos-modules.yubikey.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ opensnitch-ui virt-manager gnome.gnome-boxes ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";
  boot.kernelParams = [ "intel_iommu=off" ];

  networking.hostName = "e14";

  services.udev.extraRules =
    # Rename USB network adapter to something more useful than enp0s30p10
    # Use `lsusb` to find vendor and model
    # The external (white) USB network adapter (way faster than the one in the USB hub)
    ''
      KERNEL=="eth*", ENV{ID_VENDOR_ID}=="0b95", ENV{ID_MODEL_ID}=="1790", NAME="networkboot"
    '' +
    # Symlink serial adapters to /dev/ttyTestbox
    ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", SYMLINK+="ttyTestbox"
    '';

  hardware.opentabletdriver = {
    enable = true;
  };


  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  system.stateVersion = "22.05";
}
