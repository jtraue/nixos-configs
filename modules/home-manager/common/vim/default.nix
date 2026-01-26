{ config, lib, pkgs, inputs, ... }:

let

  cfg = config.home-modules.common.vim;

in
{

  options.home-modules.common.vim = {
    enable = lib.mkEnableOption "Enables vim.";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      (inputs.my-nixvim.lib.nixvimConfiguration {
        userConfig = {
          myNixvim.features.writing.enable = true;
        };
      })
    ];

    home.shellAliases = {
      vim = "nvim";
    };

  };
}
