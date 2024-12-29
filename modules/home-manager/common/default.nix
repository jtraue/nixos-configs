{ config, lib, pkgs, overlays, nix-colors, ... }:

let
  cfg = config.home-modules.common;
in
{
  imports = [

    nix-colors.homeManagerModule
    ./ack.nix
    ./git.nix
    ./gpg.nix
    ./mc.nix
    ./tmux
    ./vim
    ./timetracking
  ];

  options.home-modules.common = {
    enable = lib.mkEnableOption "Enables common options.";
    user = lib.mkOption {
      type = lib.types.str;
      default = "jtraue";
    };
  };

  config = lib.mkIf cfg.enable {

    colorScheme = nix-colors.colorSchemes.gruvbox-dark-pale;

    home-modules.common.ack.enable = lib.mkDefault true;
    home-modules.common.git.enable = lib.mkDefault true;
    home-modules.common.gpg.enable = lib.mkDefault true;
    home-modules.common.mc.enable = lib.mkDefault true;
    home-modules.common.tmux.enable = lib.mkDefault true;
    home-modules.common.vim.enable = lib.mkDefault true;
    home-modules.common.timetracking.enable = lib.mkDefault false;

    fonts.fontconfig.enable = true;

    nixpkgs = {
      inherit overlays;
      config = {
        allowUnfree = true;
      };
    };

    programs.command-not-found.enable = true;

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [
      cht-sh
      dos2unix
      dosfstools
      dstat
      file
      htop
      nmap
      psmisc
      qrencode
      ranger
      tldr
      pass
    ]
    ++ (with pkgs; [
      powerline-fonts
    ])
    ++ (with pkgs;
      [
        theme-switch
      ]);

    programs.zsh = {
      enable = true;

      shellAliases = {
        ls = "ls --color=auto";
        please = "sudo";
        wtf = "man";
        src = "cd ~/src";
        conf = "cd ~/conf";
        notes = "cd ~/org/notes";
        git-pull-all = "find . -maxdepth 3 -name .git -type d | rev | cut -c 6- | rev | xargs -I {} git -C {} pull";
        today = "date -u +%Y-%m-%d";
      };

      # TODO: since we have this in xsession it should be removed here?
      sessionVariables = {
        # LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
        TERM = "xterm-256color";
      };

      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.4.0";
            sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
          };
        }
      ];

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "history"
          "last-working-dir"
          "pass"
          "themes"
        ];
        theme = "gnzh";
      };

      localVariables = { ZSH_TMUX_AUTOSTART = "true"; };
    };

    home = {
      username = cfg.user;
      homeDirectory = lib.mkDefault "/home/${cfg.user}";
      stateVersion = "22.11";
    };

  };
}
