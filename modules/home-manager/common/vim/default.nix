{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.common.vim;
in
{

  options.home-modules.common.vim.enable = lib.mkEnableOption "Enables vim.";

  config = lib.mkIf cfg.enable
    {

      home.packages = [
        (pkgs.callPackage ../../../../pkgs/vim {
          withColorSwitch = true;
          withAle = true;
          withLanguageClient = true;
          withWiki = true;
        })
        pkgs.vale
      ];
    };
}
