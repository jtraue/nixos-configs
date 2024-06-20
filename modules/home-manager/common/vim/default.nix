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
      inputs.nixvim.packages."x86_64-linux".default
    ];

    home.shellAliases = {
      vim = "nvim";
    };

    home.file.".mdlrc".text = ''
      style "${config.home.homeDirectory}/.mdl_style.rb"
    '';
    home.file.".mdl_style.rb".source = ./mdl_style.rb;

    # TODO: needs `vale sync` for styles to become available
    # let's include an activation script 
    home.file.".vale.ini".text = ''
      StylesPath = .config/vale/styles

      MinAlertLevel = suggestion
      Vocab = Base

      Packages = proselint, write-good, alex, Google

      [*]
      BasedOnStyles = Vale, proselint, write-good, Google

      write-good.E-Prime = NO
      write-good.Weasel = NO
      Vale.Spelling = NO
      Google.Acronyms = NO
    '';
  };
}
