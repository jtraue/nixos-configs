{ config, lib, ... }:
let
  cfg = config.nixos-modules.desktop.sway;
in
{
  options.nixos-modules.desktop.sway.enable = lib.mkEnableOption "Enable sway";

  config = lib.mkIf cfg.enable {
    programs.sway.enable = true;
    security.polkit.enable = true;
  };
}
