{ homeManagerModules, inputs, ... }:
{
  imports = builtins.attrValues homeManagerModules;

  my.common.enable = true;

  my.common.vim.package = inputs.my-nixvim.lib.nixvimConfiguration {
    userConfig = {
      myNixvim.features.writing.enable = false;
    };
  };

  home.stateVersion = "25.11";
}
