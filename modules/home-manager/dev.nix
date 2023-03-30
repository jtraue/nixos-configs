{ config, lib, pkgs, pkgs-unstable, ... }:

let
  cfg = config.home-modules.dev;
  # Use unstable (7.2.0) for fixing this qemu with gdb bug:
  # qemu-system-x86_64: ../hw/i386/kvm/clock.c:88: kvmclock_current_nsec: Assertion `time.tsc_timestamp <= migration_tsc' failed.
  qemu = pkgs-unstable.qemu_kvm;
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
      qemu
      ttylog
    ];

  };
}
