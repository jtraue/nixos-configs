{ homeManagerModules, ... }:
{
  imports = builtins.attrValues homeManagerModules;

  home-modules.common.enable = true;
  home-modules.desktop.enable = true;
}
