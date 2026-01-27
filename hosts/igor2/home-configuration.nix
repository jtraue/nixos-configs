{ homeManagerModules, inputs, ... }:
{
  imports = builtins.attrValues homeManagerModules;

  home-modules.common.enable = true;

  home-modules.common.vim.package = inputs.my-nixvim.lib.nixvimConfiguration {
    userConfig = {
      myNixvim.features.writing.enable = false;
    };
  };

  home.stateVersion = "25.11";
}
