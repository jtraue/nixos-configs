{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nixos-modules.work;
in
{
  options.nixos-modules.work = {
    enable = mkEnableOption "Enable work settings";
  };

  config = mkIf cfg.enable {

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    nix = {
      settings = {
        trusted-public-keys = [
          "cyberus-1:0jjMD2b+guloGW27ZToxDQApCoWj+4ONW9v8VH/Bv0Q="
          "binary-cache.vpn.cyberus-technology.de:qhg25lVqyCT4sDOqxY6GJx8NF3F86eAJFCQjZK/db7Y="
        ];
        substituters = [
          "http://binary-cache-v2.vpn.cyberus-technology.de"
        ];
      };
    };

    # Our custom internal root CA.
    security.pki.certificates = [
      ''
        cyberus-technology.de
        -----BEGIN CERTIFICATE-----
        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
        9vIDicoYRwgmB8Qr7FiQo+A1Fqqa
        -----END CERTIFICATE-----
      ''
    ];

    programs.ssh = {
      knownHosts = {
        mount-koma = {
          hostNames = [ "mount-koma" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuzRwMqFmMp1bSNVqsMscVK081nI4b6t2jdgHKokKh+";
        };
        olympus-mons = {
          hostNames = [ "olympus-mons" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJK7yvt1VzMUVKDoAI7ccST63K6YCh514LsFyYt3XMc2";
        };
        build01 = {
          hostNames = [ "build01" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwdIPCDHFhao84ZoHgphp+hzYH9ot+L2gSDFD8HrMyw";
        };
      };
      extraConfig = ''
        Host mount-koma
          User jana
          HostName mount-koma
          IdentityAgent /run/user/1001/gnupg/S.gpg-agent.ssh

        Host olympus-mons
          User jana
          HostName olympus-mons
          IdentityAgent /run/user/1001/gnupg/S.gpg-agent.ssh

        Host mount-doom
          User jana
          HostName mount-doom

        Host mount-hood
          User jtraue
          HostName mount-hood
          port 2222

        Host testbox
          User jtraue
          HostName 10.0.0.10
          IdentityAgent /run/user/1001/gnupg/S.gpg-agent.ssh

        Host thinkstation
          User jtraue
          HostName 10.0.0.11
          IdentityAgent /run/user/1001/gnupg/S.gpg-agent.ssh

        Host l14
          User jtraue
          HostName 10.0.0.14
          IdentityAgent /run/user/1001/gnupg/S.gpg-agent.ssh

        Host vpn.cyberus-technology.de
          User jana
          Hostname vpn.cyberus-technology.de
          Port 8822
          IdentityAgent /run/user/1001/gnupg/S.gpg-agent.ssh

        Host nixos-live
          User jtraue
          Host 10.0.0.16
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
          IdentityAgent /run/user/1001/gnupg/S.gpg-agent.ssh

        Host localrun-demo-host
          User jtraue
          Host 10.0.0.17
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
          IdentityAgent /run/user/1001/gnupg/S.gpg-agent.ssh
      '';
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        brlaser
        brgenml1lpr
        brgenml1cupswrapper
        mfcl8690cdwcupswrapper
      ];
    };
    services.avahi = {
      enable = true;
      nssmdns = true;
    };

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
    users.extraGroups.vboxusers.members = [ config.nixos-modules.common.user ];

    services.onedrive.enable = true;

  };
}
