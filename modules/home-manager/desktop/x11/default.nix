{ config, lib, ... }:

let
  cfg = config.home-modules.desktop.x11;
in
{

  imports = [
    ./i3.nix
    ./rofi.nix
  ];

  options.home-modules.desktop.x11.enable = lib.mkEnableOption "Enables x11.";

  config = lib.mkIf cfg.enable {
    home-modules.desktop.i3.enable = true;
    home-modules.desktop.rofi.enable = true;
  };
}
