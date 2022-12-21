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

      home.file =
        let
          sources = import ../../../../nix/sources.nix;
          valeStyles = pkgs.stdenv.mkDerivation {
            name = "vale-styles";
            buildCommand = ''
              mkdir -p $out/styles
              cp -r ${sources.vale-style-google}/Google $out/styles
            '';
          };
        in
        {
          ".vale.ini" = {
            text = ''
              StylesPath = ${valeStyles}/styles
              MinAlertLevel = warning
              [*.{org,md}]
              BasedOnStyles = Google
            '';
          };
        };

    };
}
