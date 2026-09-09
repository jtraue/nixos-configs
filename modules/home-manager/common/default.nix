{ config, lib, pkgs, osConfig ? null, ... }:

let
  cfg = config.my.common;

  # `osConfig` is only set (see home-manager's nixos/common.nix specialArgs)
  # when this module runs embedded via the NixOS home-manager module. In that
  # case, `useGlobalPkgs` already shares the system's `pkgs` (with its own
  # `nixpkgs.config.allowUnfree`), and setting `nixpkgs.config` here as well
  # is deprecated/disallowed. Only fall back to setting it ourselves for a
  # true standalone home-manager configuration.
  useGlobalPkgs = osConfig != null && (osConfig.home-manager.useGlobalPkgs or false);
in
{
  imports = [
    ./ack.nix
    ./git.nix
    ./mc.nix
    ./tmux
    ./vim.nix
  ];

  options.my.common = {
    enable = lib.mkEnableOption "common user settings (shell, git, vim, tmux)";
    user = lib.mkOption {
      type = lib.types.str;
      default = "jtraue";
    };
  };

  config = lib.mkIf cfg.enable {
    my.common.ack.enable = lib.mkDefault true;
    my.common.git.enable = lib.mkDefault true;
    my.common.mc.enable = lib.mkDefault true;
    my.common.tmux.enable = lib.mkDefault true;
    my.common.vim.enable = lib.mkDefault true;

    fonts.fontconfig.enable = true;

    nixpkgs = lib.mkIf (!useGlobalPkgs) {
      config = {
        allowUnfree = true;
      };
    };

    # application icons are missing in gnome for apps installed by home-manager otherwise
    targets.genericLinux.enable = true;

    programs.command-not-found.enable = true;

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [
      cht-sh
      claude-code
      dos2unix
      dosfstools
      drawio
      file
      btop
      nerd-fonts.symbols-only
      nmap
      pass
      powerline-fonts
      psmisc
      qrencode
      ranger
      tldr
    ];

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
    };

  };
}
