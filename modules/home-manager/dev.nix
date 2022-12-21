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
      gdb
      minicom
      ninja
      nodePackages.mermaid-cli
      qemu_kvm
      ttylog
    ];

  };
}
