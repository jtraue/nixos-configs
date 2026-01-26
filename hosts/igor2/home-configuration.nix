{ homeManagerModules, ... }:
{
  imports = builtins.attrValues homeManagerModules;

  home-modules.common.enable = true;

  home.stateVersion = "25.11";
}
