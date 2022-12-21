{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nixos-modules.work;
  ipxeConfig = ./ipxe-default.cfg;
in
{
  options.nixos-modules.work = {
    enable = mkEnableOption "Enable work settings" // {
      description = "Work settings unrelated to dev setup (such as ssh configs, binary cache, ...)";
    };

    networkboot = {
      enable = mkEnableOption (mdDoc "Enable network boot server.") // {
        default = false;
      };
      networkInterface = mkOption {
        type = types.str;
        description = mdDoc ''
          Ethernet device which the server manages.

          ::: {.note}
          It might be handy to rename your network interfaces via udev rules.
          Use `lsusb` to find vendor and model such as:
          ```
          Bus 004 Device 006: ID 0bda:8153 Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter
          ```
          The corresponding udev rule:
          ```
          services.udev.extraRules = '''
            KERNEL == "eth*", ENV{ID_VENDOR_ID}=="0b95", ENV{ID_MODEL_ID}=="1790", NAME="networkboot"
          ''';
          ```
        '';
        default = "networkboot";
      };
      tftpFolder = mkOption {
        type = types.str;
        description = mdDoc ''
          Path to TFTP folder.

          A TFTP server uses this as root folder.
          iPXE binaries are installed to this folder.
        '';
        default = "/var/lib/tftp";
      };
    };

    usb3debug = mkOption {
      type = types.bool;
      description = "TODO (not used for a long time)";
      default = false;
    };

    enablePrinting = mkEnableOption "Enable Office Printer Supprt" // {
      description = "Install Printer drivers";
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{

      nix = {
        settings = {
          trusted-public-keys = [
            "binary-cache.vpn.cyberus-technology.de:qhg25lVqyCT4sDOqxY6GJx8NF3F86eAJFCQjZK/db7Y="
            "cyberus-1:0jjMD2b+guloGW27ZToxDQApCoWj+4ONW9v8VH/Bv0Q="
          ];
          trusted-substituters = [
            "https://binary-cache.vpn.cyberus-technology.de"
            "http://binary-cache-v2.vpn.cyberus-technology.de"
          ];
        };
        # 1st line: optional, useful when the builder has a faster internet connection than yours
        extraOptions = ''
          builders-use-substitutes = true
          # See https://discourse.nixos.org/t/precedence-with-multiple-substituters/1191 for a discussion about priorities.
          extra-substituters = http://binary-cache-v2.vpn.cyberus-technology.de https://binary-cache.vpn.cyberus-technology.de
        '';
        buildMachines = [
          {
            hostName = "build01";
            system = "x86_64-linux";
            systems = [ "x86_64-linux" "aarch64-linux" "armv7l-linux" ];
            maxJobs = 20;
            speedFactor = 1;
            supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
            mandatoryFeatures = [ ];
            sshUser = "jana";
          }
        ];
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

          Host vpn.cyberus-technology.de
            User jana
            Hostname vpn.cyberus-technology.de
            Port 8822
            IdentityAgent /run/user/1001/gnupg/S.gpg-agent.ssh
        '';
      };

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    }

      (mkIf cfg.usb3debug {
        services.udev.extraRules = ''
              ACTION =="add", SUBSYSTEM =="usb", ATTRS{idVendor}=="ffff", ATTRS{idProduct}=="0001", RUN+="${pkgs.kmod}/bin/modprobe usbserial" RUN+="${pkgs.bash}/bin/bash -c 'echo ffff 0001 > /sys/bus/usb-serial/drivers/generic/new_id'"
          ATTRS{idVendor}=="ffff", ATTRS{idProduct}=="0001", ENV{ID_MM_DEVICE_IGNORE}="1"
        '';
      })

      (mkIf cfg.networkboot.enable {

        environment.systemPackages = [
          pkgs.nodePackages.meshcommander
        ];

        networking = {
          firewall = {
            allowedUDPPorts = [
              67 # dhcp/dnsmasq
              69 # tftp
              8888 # For running temporary HTTP server via `nix-shell -p python3Packages.python --run 'python3 -m http.server 8888'`
              8889 # Also temporary HTTP server.
              20633
            ];
            allowedTCPPorts = [
              8888 # darkhttp (started via 'darkhttpd /tmp/out --addr 10.0.0.1 --port 8888'
              8889
              20633
            ];
          };
          # networkmanager = {
          # unmanaged = cfg.networkInterfaces;
          # };
        };

        services = {
          dhcpd4 = {
            enable = true;
            interfaces = [ cfg.networkboot.networkInterface ];
            machines = [
              {
                hostName = "testbox_home";
                ethernetAddress = "b4:2e:99:a1:59:29"; # this is amt
                ipAddress = "10.0.0.10";
              }
              {
                hostName = "thinkstation";
                ethernetAddress = "90:2e:16:d1:c5:25";
                ipAddress = "10.0.0.11";
              }
              {
                hostName = "legacy_nuc";
                ethernetAddress = "b8:ae:ed:75:58:b1";
                ipAddress = "10.0.0.13";
              }

            ];
            extraConfig = ''
              subnet 10.0.0.0 netmask 255.255.255.0 {
                range 10.0.0.150 10.0.0.199;
                next-server 10.0.0.1;
              }
              class "pxeclient" {
                match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
                if substring (option vendor-class-identifier, 15, 5) = "00000" {
                  filename "ipxe.kpxe";
                }
                else {
                  filename "ipxe.efi";
                }
              }
            '';
          };
          atftpd = {
            enable = true;
            root = cfg.networkboot.tftpFolder;
          };
        };

        # We are going to start this server via `systemctl start networkboot` manually
        # to speed up boot time and enable traveling.
        systemd.targets.networkboot = {
          wantedBy = [ "non_existing.target" ];
          after = [ "multi-user.target" ];
        };

        systemd.services = {
          dhcpd4 = {
            after = [ "networkboot.target" ];
            wantedBy = lib.mkForce [ "networkboot.target" ]; # covers stop/restart
            partOf = [ "networkboot.target" ]; # covers start
          };
          "network-addresses-${cfg.networkboot.networkInterface}" = {
            partOf = [ "networkboot.target" ];
            wantedBy = lib.mkForce [ "networkboot.target" ];
          };
          tftp-permissions = {
            enable = true;
            before = [ "dnsmasq.service" ];
            description = "Set permissions of TFTP folder";
            wantedBy = [ "networkboot.target" ];
            partOf = [ "networkboot.target" ];

            # Ship files.
            # TODO: Do this during activation only.
            preStart = ''
              ${pkgs.coreutils}/bin/mkdir -p ${cfg.networkboot.tftpFolder}
              ${pkgs.coreutils}/bin/cp ${pkgs.ipxe}/undionly.kpxe  ${cfg.networkboot.tftpFolder}/ipxe.kpxe
              ${pkgs.coreutils}/bin/cp ${pkgs.ipxe}/ipxe.efi  ${cfg.networkboot.tftpFolder}
              ${pkgs.coreutils}/bin/cp ${ipxeConfig} ${cfg.networkboot.tftpFolder}/ipxe-default.cfg
            '';
            # Change file permissions (because we copy read only files and may want to change/replace them during experiments).
            serviceConfig = {
              Type = "simple";
              ExecStart =
                let
                  script = pkgs.writeScript "tftp-permissions" ''
                    ${pkgs.coreutils}/bin/chmod a+rwx ${cfg.networkboot.tftpFolder}
                    ${pkgs.coreutils}/bin/chmod -R a+rw ${cfg.networkboot.tftpFolder}
                  '';
                in
                "${pkgs.bash}/bin/bash ${script}";
            };
          };
        };

        # Frequently restore permissions.
        systemd.timers = {
          tftp-permissions = {
            timerConfig = {
              AccuracySec = "1s";
              OnCalendar = "*:*:0";
            };
          };
        };

        # To share folders via sshfs with testbox.
        services.sshd.enable = true;
        services.openssh.listenAddresses = [{
          addr = "10.0.0.1";
          port = 22;
        }];
        users.users.jtraue.openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfjY3PNFC991Td5GdY+JCCfgocj7W6Siq9L6U+Uz8C9NfOMWMT3ipsx9Ai0X+cKOdpqPwOiBE7B9xGeVkdrj3CJPGDiJxhsqBb+EjgyeSYwx49gGLwidQm8Vckx5Kw9AclNW6wSn1vCLUWp+UJ8Ml8ZDQXYnBuAFj0LgGKJwbY9AJO0KlAdhQbO4K/TvDfYUz/GQp0coFQy2Iu4P6oZHv3AOxUPTJJesJKEIAKvkG9TEyU36QYF+o2DdzRwYslnSMNXLgFccRXy1prlDjYJxVY/bBdsH4O/Yg/unbRzh71Z0ww9nIx0P3rn1wMvL4/4yIC5kdLI9RRtV5IHgS7XMmx6VcCP5Jt0ZJf9w7Iy42/bZcmkhT94UD3gPzVaeOaPqaaXjjeDoxJ20cy/v1tUEbWzHOKomTQ0a7ymAomSD62U/mp8Sti10XM82gisk9US07y6DXB1eX1Shogj5X7KELmWTI4gqvEin9dIiVQ/OotGoPEcJl1sEfa/LWQoMcvwQM= jtraue@testbox"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3h4FW/3dU+rr0tCgBwvIDxpi2AsicGxswoBa5InmZHo9LFelOCE01Be/Py2VaWv3+DJHKQnQEZX3jV1zUtZiiKimH/8rXGBDZR8oGrm05Nm9OOEeyN3GzFaOHPWqw1fHEI2JMwX9WL6mEqJAcUdMAOEi0o8QAO5hSeQZyEmsuuGA5vOfdhUxSX3G3dwWEvHBNtUTe+v2x5koDcTSJZAPs2417hIyGMd1imCtDmr6pxByHT8NgSvuC+S4I5pv6zMpBfhHfNdjw8/oCxfTdsTSzSgl5rvhCQNB5UXbBEnRPb1Zu/Wyyjc6O9pa6SytJKOIO7rMmdxASftvpXEcHwWsDcVq73ZDycJdbW6V5pLHHNRQr7DdqJ04LSXPvhctyolKyAkjSTshdjnboED5x9XdD561YCseP7mVEHiDz0XJTnikayson+UAVYlN9GIMkk3QKGsGi85/CXXO+h/uSQ9rtFikM3aJz7zKDmhIblemlzwKw4JoF+3Hh2EaSs7sRkRU= jtraue@thinkstation"
        ];
      })

      (mkIf cfg.enablePrinting {
        services.printing = {
          enable = true;
          drivers = with pkgs; [
            gutenprint
            hplip
            brlaser
            brgenml1lpr
            brgenml1cupswrapper
          ];
        };
        services.avahi = {
          enable = true;
          nssmdns = true;
        };
      })]
  );
}
