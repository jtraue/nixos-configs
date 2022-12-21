{ config, lib, pkgs, ... }:
let
  cfg = config.nixos-modules.notebook;
in
{
  options.nixos-modules.notebook.enable = lib.mkEnableOption "Enable notebook settings.";

  config = lib.mkIf cfg.enable {

    hardware = {
      trackpoint = {
        emulateWheel = true;
        fakeButtons = true;
      };
    };


    # -- power
    powerManagement.enable = true;
    environment.systemPackages = with pkgs; [
      powertop
    ];

    services.acpid.enable = true;

  };
}
