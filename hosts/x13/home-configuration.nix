{ lib, pkgs, homeManagerModules, ... }:
{
  imports = builtins.attrValues homeManagerModules;

  home-modules.common.enable = true;
  home-modules.desktop.enable = true;
  home-modules.dev.enable = true;


  home.file.".abcde.conf".text = ''
    PADTRACKS=y
    OUTPUTDIR=~/media
    OUTPUTTYPE=mp3
    EJECTCD=y
  '';

  home.packages = with pkgs; [
    abcde
    digikam
    sweethome3d.application
    snapmaker-luban
    freecad
    krita
    drawio
  ] ++ [
    pkgs.screenrotate
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "igor" = {
        hostname = "igor";
        user = "root";
      };
      "kirby" = {
        hostname = "kirby";
        user = "jana";
      };
    };
  };
}
