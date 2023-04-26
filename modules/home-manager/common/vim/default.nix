{ config, lib, pkgs, ... }:

let

  cfg = config.home-modules.common.vim;

  diaryHelper = pkgs.writeShellScriptBin "diary_helper" ''
    cat << EOF
    # $(date +'%Y WEEK %U')

    # TODO

    EOF
  '';
  meetingHelper = pkgs.writeShellScriptBin "meeting_helper" ''
    cat << EOF
    # $(date +'%Y-%m-%d')

    ## Attendees

    ## Agenda

    [toc]

    ## Action Items

    EOF
  '';

  vimwiki-dev = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vimwiki-dev";
    version = "2023-04-05";
    src = pkgs.fetchFromGitHub {
      owner = "vimwiki";
      repo = "vimwiki";
      rev = "71edcf6802eeb724ca679547d5cb7a8eadf0cfcb";
      sha256 = "sha256-Z5XMtVszorh+gnjT5HxdmjOdV9gUVL2m/wKeEIlgCDA=";
    };
  };

in
{

  options.home-modules.common.vim = {
    enable = lib.mkEnableOption "Enables vim.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep # for telescope's live grep

      nixpkgs-fmt
      statix
      shellcheck
      deadnix
      proselint
      mdl
      nodePackages.prettier
      cmake-format
      yamllint

      nil
      nodePackages.bash-language-server
      sumneko-lua-language-server
      clang-tools

      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })

      diaryHelper
      meetingHelper
    ];
    # If fonts don't seem to work, try nvim in a new terminal.
    fonts.fontconfig.enable = true;

    programs.neovim =
      {
        enable = true;
        viAlias = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [
          # Telescope
          telescope-nvim
          telescope-fzf-native-nvim
          plenary-nvim

          # Git
          fugitive

          # Eye candy
          vim-colorschemes
          bufferline-nvim
          indent-blankline-nvim
          nvim-treesitter.withAllGrammars
          nvim-web-devicons
          lualine-nvim

          # Lsp
          nvim-lspconfig
          lsp_extensions-nvim
          nvim-code-action-menu
          trouble-nvim
          null-ls-nvim
          nvim-lightbulb
          fidget-nvim
          nvim-code-action-menu

          # Improve startup time
          # impatient-nvim

          # Autocompletion
          nvim-cmp
          cmp-nvim-lsp
          cmp-nvim-lua
          cmp-nvim-lsp-signature-help
          cmp-vsnip
          cmp-path
          cmp-buffer

          # File browser
          nvim-tree-lua

          vimwiki-dev
          comment-nvim
          markdown-preview-nvim
          cheatsheet-nvim
          gitsigns-nvim
        ];
      };

    xdg.configFile.nvim = {
      source = ./nvim;
      recursive = true;
    };
    home.file.".mdlrc".text = ''
      style "${config.home.homeDirectory}/.mdl_style.rb"
    '';
    home.file.".mdl_style.rb".source = ./mdl_style.rb;
  };
}
