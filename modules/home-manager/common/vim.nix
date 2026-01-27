{ config, lib, pkgs, inputs, ... }:

let

  cfg = config.home-modules.common.vim;

in
{

  options.home-modules.common.vim = {
    enable = lib.mkEnableOption "Enables vim.";
    package = lib.mkOption {
      type = lib.types.package;
      inherit (inputs.my-nixvim.packages.${pkgs.stdenv.hostPlatform.system}) default;
      description = "Vim package to use";
    };
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      cfg.package
    ];

    home.shellAliases = {
      vim = "nvim";
    };

  };
}
