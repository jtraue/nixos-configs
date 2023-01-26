{ config, lib, pkgs, overlays, ... }:

let
  cfg = config.home-modules.common;
in
{
  imports = [
    ./ack.nix
    ./git.nix
    ./gpg.nix
    ./mc.nix
    ./tmux
    ./vim
  ];

  options.home-modules.common.enable = lib.mkEnableOption "Enables common options.";

  config = lib.mkIf cfg.enable {
    home-modules.common.ack.enable = lib.mkDefault true;
    home-modules.common.git.enable = lib.mkDefault true;
    home-modules.common.gpg.enable = lib.mkDefault true;
    home-modules.common.mc.enable = lib.mkDefault true;
    home-modules.common.tmux.enable = lib.mkDefault true;
    home-modules.common.vim.enable = lib.mkDefault true;

    fonts.fontconfig.enable = true;

    nixpkgs = {
      overlays = builtins.attrValues overlays;
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
      youtube-dl
    ]
    ++ (with pkgs; [
      font-awesome
      powerline-fonts
    ])
    ++ (with pkgs;
      [
        theme-switch
        taskwarrior-tui
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
      };

      # TODO: since we have this in xsession it should be removed here?
      sessionVariables = {
        # LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
        TERM = "xterm-256color";
      };

      initExtra = /* zsh */ ''
        bindkey "\e$terminfo[kcub1]" backward-word
        bindkey "\e$terminfo[kcuf1]" forward-word
         if [[ -n "$IN_NIX_SHELL" ]]; then
          label="nix-shell"
          if [[ "$name" != "$label" ]]; then
            label="$label:$name"
          fi
          export PS1=$'%{$fg[green]%}'"$label$PS1"
          unset label
        fi
      '';

      initExtraBeforeCompInit = /* zsh */ ''
        ZSH_TMUX_AUTOSTART=true
        ZSH_TMUX_AUTOQUIT=true
        ZSH_TMUX_AUTOCONNECT=false
        # open markdown files with vim
        alias -s md=vim
      '';

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
        theme = "agnoster";
      };
    };

    programs.taskwarrior = {
      enable = true;
      dataLocation = "~/.task";
      colorTheme = "solarized-dark-256";
      extraConfig = ''
        weekstart = monday
      '';
    };

    home = {
      username = "jtraue";
      homeDirectory = "/home/jtraue";
      stateVersion = "22.11";
    };

  };
}
