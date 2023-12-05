{ homeManagerModules, ... }:
{
  imports = builtins.attrValues homeManagerModules;

  home-modules.common.enable = true;
  home-modules.desktop.enable = true;
  home-modules.desktop.x11.enable = false;
  home-modules.desktop.sway.enable = true;
  home-modules.dev.enable = false;
  home-modules.usbbackup.enable = false;
  home-modules.common.timetracking.enable = false;

  programs.git = {
    userEmail = "jana.traue@cyberus-technology.de";
  };

}
