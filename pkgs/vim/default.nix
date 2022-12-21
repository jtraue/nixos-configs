{ writeShellScriptBin
, lib
, neovim
, vimPlugins
, withColorSwitch ? false
, withAle ? false
, withLanguageClient ? false
, withWiki ? false
, pkgs
}:
let

  cmakelint = pkgs.python3.pkgs.buildPythonApplication rec {
    pname = "cmakelint";
    version = "1.4";

    src = pkgs.python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0y79rsjmyih9iqrsgff0cwdl5pxvxbbczl604m8g0hr1rf0b8dlk";
    };

    doCheck = false;

    meta = {
      homepage = "https://github.com/richq/cmake-lint";
      description = "cmakelint parses CMake files and reports style issues.";
    };
  };

  vimwiki-dev = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vimwiki-dev";
    version = "2022-03-20";
    src = pkgs.fetchFromGitHub {
      owner = "vimwiki";
      repo = "vimwiki";
      rev = "4d7a4da2e8e2fff34126e32d8818ba93c66a8a75";
      sha256 = "sha256-G4qfzRzGTZPS/zoYQD0183bYTwsvd+TnhPXiQmn2WvY=";
    };
  };

  getSettingsValueForKey = key: setting: if lib.hasAttr key setting then [ (lib.getAttr key setting) ] else [ ];
  getAllConfigs = settings: lib.concatLists (lib.forEach (lib.flatten settings) (getSettingsValueForKey "config"));
  getAllPlugins = settings: lib.flatten (lib.forEach (lib.flatten settings) (getSettingsValueForKey "plugins"));
  getAllPackages = settings: lib.flatten (lib.forEach (lib.flatten settings) (getSettingsValueForKey "extraPackages"));

  settings = [
    {
      # lualine
      # null-ls
      # neogit
      # dracula colortheme
      # orgmode
      config = builtins.readFile ./vimrc/general.vim;
      plugins = with vimPlugins; [
        bufexplorer
        fugitive # we use the system wide git - make sure to install it
        gitgutter
        markdown-preview-nvim
        nerdcommenter
        rainbow
        vim-airline
        vim-airline-themes
        # lualine-nvim
        # nvim-navic
        vim-colorschemes
        vim-devicons
        vim-localvimrc
        vim-table-mode
        vim-nix
        vim-plugin-AnsiEsc
        nvim-treesitter
        telescope-nvim
        # neogit
      ];
    }
    # {
    # config = builtins.readFile ./vimrc/dap.vim;
    # plugins = with vimPlugins; [
    # nvim-dap
    # nvim-dap-ui
    # ];
    # }
    {
      config = builtins.readFile ./vimrc/nerdtree.vim;
      plugins = with vimPlugins; [
        nerdtree
      ];
    }
    {
      config = builtins.readFile ./vimrc/autoformat.vim;
      plugins = with vimPlugins; [
        vim-autoformat
        vim-clang-format
      ];
      extraPackages = with pkgs; [
        clang-tools
        cmake-format
        nixpkgs-fmt
        yapf
      ];
    }
  ]
  ++ (lib.optionals withColorSwitch [{
    config = builtins.readFile ./vimrc/colorswitch.vim;
  }])
  ++ (lib.optionals withAle [{
    config = builtins.readFile ./vimrc/ale.vim;
    plugins = with vimPlugins; [
      ale
    ];
    extraPackages = with pkgs;[
      aspell
      aspellDicts.de
      aspellDicts.en
      bashate
      cmakelint
      flawfinder
      mdl
      proselint
      shellcheck
      statix
      vale
    ];
  }])
  ++ (lib.optionals withLanguageClient [{
    config = builtins.readFile ./vimrc/lcn.vim;
    plugins = with vimPlugins; [
      LanguageClient-neovim
      nvim-lspconfig
      lsp-status-nvim
    ];
    extraPackages = with pkgs;[
      clang-tools
      rust-analyzer
      rnix-lsp
    ];
  }])
  ++ (lib.optionals withWiki [{
    config =
      let
        cfg = pkgs.substituteAll {
          src = ./vimrc/wiki.vim;
          wiki = "~/cloud/home/wiki/notes";
        };
      in
      "source ${cfg}";
    plugins = with vimPlugins; [
      vimwiki-dev
    ];
    extraPackages =
      let
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
      with pkgs;[
        rust-analyzer
        diaryHelper
        meetingHelper
      ];
  }]);

  vim = neovim.override {
    configure = {
      customRC = lib.concatStringsSep "\n" (getAllConfigs settings);
      packages.neovimPlugins = with vimPlugins; {
        start = getAllPlugins settings ++ getAllPackages settings;
      };
    };
  };
in
writeShellScriptBin "vim" ''
  export PATH="${lib.makeBinPath (getAllPackages settings)}:$PATH"
  ${vim}/bin/nvim $@
''
