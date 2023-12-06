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
      vale

      nil
      nixd
      nodePackages.bash-language-server
      sumneko-lua-language-server
      clang-tools

      djhtml

      nodePackages.vscode-langservers-extracted

      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })

      diaryHelper
      meetingHelper

    ] ++ (with pkgs.python3Packages; [
      python-lsp-server
      pycodestyle

      djlint
    ]);
    # If fonts don't seem to work, try nvim in a new terminal.
    fonts.fontconfig.enable = true;

    programs.neovim =
      {
        enable = true;
        viAlias = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [
          nvim-lspconfig

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

          vimwiki
          comment-nvim
          markdown-preview-nvim
          cheatsheet-nvim
          gitsigns-nvim
          vim-table-mode

          goyo-vim
          limelight-vim

          vim-floaterm

          editorconfig-nvim
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
