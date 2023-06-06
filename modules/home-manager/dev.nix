{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.dev;
in
{
  options.home-modules.dev.enable = lib.mkEnableOption "Enables development environments.";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      amtterm
      cmakeCurses
      deadnix
      gdb
      minicom
      ninja
      qemu_kvm
      ttylog
    ];

  };
}
