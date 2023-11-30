{ nixos-hardware, pkgs, ... }:
{

  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-l14-intel
  ];

  # for installation only
  users.users.demo = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  services.openssh.enable = true;

  services.onedrive.enable = true;

  nix.settings.cores = 10;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "jtraue" ];

  nixos-modules.common.enable = true;
  nixos-modules.desktop.enable = true;
  nixos-modules.desktop.x11.enable = true;
  nixos-modules.desktop.sway.enable = false;
  nixos-modules.notebook.enable = true;
  nixos-modules.work = {
    enable = true;
    enablePrinting = true;
    # networkboot.enable = true;
    # networkboot.tftpFolder = "/home/jtraue/tftp";
  };
  nixos-modules.yubikey.enable = true;

  services.dbus.packages = with pkgs; [ miraclecast ];

  # pipewire complains about missing xdg-portals (https://www.reddit.com/r/NixOS/comments/y877ou/pipewire_not_working_requires_xdgportals/)
  xdg.portal.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    opensnitch-ui
    virt-manager
    gnome.gnome-boxes
    miraclecast
  ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";
  # boot.kernelParams = [ "i915.force_probe=a720" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "l14";

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