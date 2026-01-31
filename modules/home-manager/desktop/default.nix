{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.desktop;

  browser = [ "chromium.desktop.desktop" ];

  associations = {
    "application/pdf" = [ "org.kde.okular.desktop" ];
    # "inode/directory" = [ "pcmanfm.desktop" ];
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;
  };

in
{
  imports = [
    ./gnome.nix
  ];

  options.home-modules.desktop.enable = lib.mkEnableOption "Enables desktop environment.";

  config = lib.mkIf cfg.enable {
    nixpkgs.config.input-fonts.acceptLicense = true;
    services.network-manager-applet.enable = true;

    # Allow fonts installed via home.packages to be discovered by fontconfig
    fonts.fontconfig.enable = true;

    # see nixos settings on how to enable automatic login
    services.nextcloud-client.enable = lib.mkDefault true;

    services.udiskie = {
      enable = true;
      tray = "always";
    };

    # To find the extension ID, check its URL on the web store:
    # https://chrome.google.com/webstore/category/extensions
    programs.chromium = {
      enable = true;
      extensions = [
        "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # onepassword
        "niloccemoadcdkdjlinkgdfekeahmflj" # pocket
        "dmghijelimhndkbmpgbldicpogfkceaj" # dark mode
        "oldceeleldhonbafppcapldpdifcinji" # language tool
      ];
    };

    home.packages = with pkgs; [
      arandr
      aspellDicts.de
      ffmpeg
      filezilla
      gimp
      simple-scan
      file-roller
      nautilus
      hunspell
      hunspellDicts.en-us-large
      imagemagick
      inkscape
      libreoffice
      nextcloud-client
      kdePackages.okular
      pavucontrol
      pulseaudio
      scrot # used for screenshot in xournalpp
      signal-desktop
      sxiv
      vlc
      wireshark
      xclip
      xournalpp
    ] ++ [
      pkgs.corefonts # microsoft free fonts
      pkgs.roboto
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = associations;
    };
    # Force override - home-manager activation fails if mimeapps.list exists
    # https://github.com/nix-community/home-manager/issues/1213
    xdg.configFile."mimeapps.list".force = true;

    services.redshift = {
      enable = true;
      latitude = "51.18204";
      longitude = "13.81823";
    };

  };
}
