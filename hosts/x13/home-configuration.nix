{ pkgs, homeManagerModules, ... }:
{
  imports = builtins.attrValues homeManagerModules;

  home-modules.common.enable = true;
  home-modules.desktop.enable = true;
  home-modules.dev.enable = true;

  dconf.settings = {
    # ...
    "org/gnome/shell" = {
      disable-user-extensions = false;
    };
  };


  home.file.".abcde.conf".text = ''
    PADTRACKS=y
    OUTPUTDIR=~/media
    OUTPUTTYPE=mp3
    EJECTCD=y
  '';

  nixpkgs.config.permittedInsecurePackages = [
    "snapmaker-luban-4.10.12"
    "snapmaker-luban-4.10.2"
  ];


  services.udiskie = {
    settings = {
      device_config = [
        {
          id_uuid = [ "032600a9-a94f-4f03-b16a-75b922250b39" ]; # work backup
          ignore = true;
          automount = false;
        }
      ];
    };
  };


  home.packages = with pkgs; [
    abcde
    digikam
    sweethome3d.application
    snapmaker-luban
    freecad
    krita
    drawio
  ] ++ [
    pkgs.screenrotate
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "igor" = {
        hostname = "igor";
        user = "root";
      };
      "mini" = {
        hostname = "mini.home";
        user = "kodi";
      };
    };
  };

  xsession.windowManager.i3.config = {
    startup = [
      {
        command = "${pkgs.signal-desktop}/bin/signal-desktop --use-tray-icon --start-in-tray";
        notification = false;
      }
    ];
  };
}
