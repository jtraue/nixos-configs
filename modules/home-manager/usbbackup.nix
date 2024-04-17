{ config, lib, pkgs, ... }:

# Store the key on disk. If anyone is able to access my hard drive this includes access
# all files. The backups don't contain any other information.

# To add a keyfile to an existing device.
# Identify the device:
#   sudo blkid -t TYPE=crypto_LUKS
# It is /dev/sdc1 here.
# Create key file:
#   DEST=/home/jtraue/.usbbackupkey
#   dd bs=512 count=4 if=/dev/random of=$DEST iflag=fullblock
#   nix-shell -p openssl --run 'openssl genrsa-out $DEST 4096'
#   chmod -v 0400 $DEST
# Add it:
#   sudo cryptsetup luksAddKey /dev/sdc1 $DEST

let
  cfg = config.home-modules.usbbackup;
in
{

  # Keep in mind that you need ervices.udisks2.enable in your NixOS configuration.
  options.home-modules.usbbackup.enable = lib.mkEnableOption "Enables usbbackup.";

  config = lib.mkIf cfg.enable {

    services.udiskie = {
      enable = true;
      tray = "always";
      settings = {
        device_config = [{
          # You can get the UUID of your device from e.g.:
          # ls -la /dev/disk/by-uuid/,
          # sudo lsblk -f
          id_uuid = "032600a9-a94f-4f03-b16a-75b922250b39";
          keyfile = "~/.usbbackupkey";
        }];
      };
    };

    home.packages = with pkgs; [
      vorta
    ];
  };
}
