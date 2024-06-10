{ config, lib, pkgs, ... }:
let
  cfg = config.nixos-modules.yubikey;
in
{
  options.nixos-modules.yubikey.enable = lib.mkEnableOption "Enable yubikey.";

  config = lib.mkIf cfg.enable {

    # Setup a new yubikey when using multiple ones:
    # gpg-connect-agent "scd serialno" "learn --force" /bye

    # To disable OTP:
    #   nix-shell -p yubikey-manager-qt
    #   ykman-gui
    #   Interfaces -> OTP
    environment.shellInit = ''
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
    '';

    programs = {
      ssh.startAgent = false;
      gnupg = {
        package = pkgs.gnupg;
        agent = {
          enable = true;
          enableSSHSupport = true;
        };
      };
    };

    services = {
      pcscd = {
        enable = true;
        plugins = [ pkgs.ccid ];
      };
      udev = {
        packages = [ pkgs.libu2f-host ];
      };
    };

    environment.systemPackages = with pkgs; [
      yubikey-personalization-gui
      pcsctools
    ];

  };
}
