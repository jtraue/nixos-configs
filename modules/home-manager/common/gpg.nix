{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.common.gpg;
in
{

  options.home-modules.common.gpg.enable = lib.mkEnableOption "Enables gpg.";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnupg
    ];

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
      enableScDaemon = true;
    };

    home.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/$UID/gnupg/S.gpg-agent.ssh";
    };

  };
}
