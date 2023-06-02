{ nixos-hardware, pkgs, ... }:
{

  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel
  ];

  nixos-modules.common.enable = true;
  nixos-modules.desktop.enable = true;
  nixos-modules.desktop.x11.enable = true;
  nixos-modules.desktop.sway.enable = false;
  nixos-modules.notebook.enable = true;
  nixos-modules.work = {
    enable = true;
    networkboot.enable = true;
    enablePrinting = true;
    networkboot.tftpFolder = "/home/jtraue/tftp";
  };
  nixos-modules.yubikey.enable = true;

  # pipewire complains about missing xdg-portals (https://www.reddit.com/r/NixOS/comments/y877ou/pipewire_not_working_requires_xdgportals/)
  xdg.portal.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "jtraue" ];

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager gnome.gnome-boxes ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";
  boot.kernelParams = [ "intel_iommu=off" ];

  # -- network
  # Note for future me: nmtui can be used for network config on terminal
  networking = {
    hostName = "e14";
    networkmanager = {
      unmanaged = [ "networkboot" ];
    };
    interfaces.networkboot.ipv4 = {
      addresses = [{ address = "10.0.0.1"; prefixLength = 24; }];
    };
  };

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
