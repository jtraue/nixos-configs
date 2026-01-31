{ config, lib, pkgs, ... }:

let
  cfg = config.my.common.ack;
in
{

  options.my.common.ack.enable = lib.mkEnableOption "Enables ack.";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ ack ];
    home.file.".ackrc".source = ./ackrc;
  };
}
