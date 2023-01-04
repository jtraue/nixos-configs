{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.common.vim;

  getSettingsValueForKey = key: setting: if lib.hasAttr key setting then [ (lib.getAttr key setting) ] else [ ];
  getAllConfigs = settings: lib.concatLists (lib.forEach (lib.flatten settings) (getSettingsValueForKey "config"));
  getAllPlugins = settings: lib.flatten (lib.forEach (lib.flatten settings) (getSettingsValueForKey "plugins"));
  getAllPackages = settings: lib.flatten (lib.forEach (lib.flatten settings) (getSettingsValueForKey "extraPackages"));

  inherit (pkgs) vimPlugins;

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

in
{

  options.home-modules.common.vim = {
    enable = lib.mkEnableOption "Enables vim.";

    withColorSwitch = lib.mkOption {
      type = lib.types.bool;
      description = "Enables dynamic color switch.";
      default = false;
    };
    withAle = lib.mkOption {
      type = lib.types.bool;
      description = "Enables ALE.";
      default = false;
    };
    withLanguageClient = lib.mkOption {
      type = lib.types.bool;
      description = "Enables language client.";
      default = false;
    };
    withWiki = lib.mkOption {
      type = lib.types.bool;
      description = "Enables vimwiki.";
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.neovim =
      let
        settings = [
          {
            config = builtins.readFile ./vimrc/general.vim;
            plugins = with pkgs.vimPlugins; [
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
            ];
          }
        ]
        ++ [{
          config = builtins.readFile ./vimrc/autoformat.vim;
          plugins = with vimPlugins; [
            vim-autoformat
            vim-clang-format
          ];
          extraPackages = with pkgs;[
            clang-tools
            cmake-format
            nixpkgs-fmt
            yapf
          ];
        }]
        ++ (lib.optionals cfg.withColorSwitch [{
          config = builtins.readFile ./vimrc/colorswitch.vim;
        }])
        ++ (lib.optionals cfg.withAle [{
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
        ++ (lib.optionals cfg.withLanguageClient [{
          config = builtins.readFile ./vimrc/lcn.vim;
          plugins = with vimPlugins; [
            LanguageClient-neovim
            nvim-lspconfig
            lsp-status-nvim
            null-ls-nvim
          ];
          extraPackages = with pkgs;[
            clang-tools
            rust-analyzer
            rnix-lsp
            gitlint
          ];
        }])
        ++ (lib.optionals cfg.withWiki [{
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
      in
      {
        enable = true;
        viAlias = true;
        vimAlias = true;
        extraConfig = lib.concatStringsSep "\n" (getAllConfigs settings);
        extraPackages = getAllPackages settings;
        plugins = getAllPlugins settings;
      };
  };
}
