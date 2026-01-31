{ config, lib, pkgs, inputs, ... }:

let

  cfg = config.my.common.vim;

in
{

  options.my.common.vim = {
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
