{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.desktop;

  browser = [ "chromium.desktop.desktop" ];

  associations = {
    "application/pdf" = [ "org.kde.okular.desktop" ];
    "inode/directory" = [ "pcmanfm.desktop" ];
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
    ./autorandr.nix
    ./i3.nix
    ./kitty.nix
    ./rofi.nix
  ];

  options.home-modules.desktop.enable = lib.mkEnableOption "Enables desktop environment.";

  options.home-modules.desktop.solarized = lib.mkOption {
    type = lib.types.attrs;
    description = "solarized colors";
    default =
      {
        dark = "#00252E";
        base03 = "#002b36";
        base02 = "#073642";
        base01 = "#586e75";
        base00 = "#657b83";
        base0 = "#839496";
        base1 = "#93a1a1";
        base2 = "#eee8d5";
        base3 = "#fdf6e3";
        yellow = "#b58900";
        orange = "#cb4b16";
        red = "#dc322f";
        magenta = "#d33682";
        violet = "#6c71c4";
        blue = "#268bd2";
        cyan = "#2aa198";
        green = "#859900";
      };
  };

  config = lib.mkIf cfg.enable {

    home-modules.desktop.autorandr.enable = true;
    home-modules.desktop.kitty.enable = true;
    home-modules.desktop.i3.enable = true;
    home-modules.desktop.rofi.enable = true;

    nixpkgs.config.input-fonts.acceptLicense = true;
    services.network-manager-applet.enable = true;

    # Allow fonts installed via home.packages to be discovered by fontconfig
    fonts.fontconfig.enable = true;

    # see nixos settings on how to enable automatic login
    services.nextcloud-client.enable = true;

    # To find the extension ID, check its URL on the web store:
    # https://chrome.google.com/webstore/category/extensions
    programs.chromium = {
      enable = true;
      extensions = [
        "gcbommkclmclpchllfjekcdonpmejbdp" # https-everywhere
        "ihlenndgcmojhcghmfjfneahoeklbjjh" # cvim
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # onepassword
        "niloccemoadcdkdjlinkgdfekeahmflj" # pocket
        "dmghijelimhndkbmpgbldicpogfkceaj" # dark mode
      ];
    };

    home.packages = with pkgs; [
      _1password-gui
      arandr
      aspellDicts.de
      ffmpeg
      filezilla
      gimp
      gnome3.simple-scan
      hunspell
      hunspellDicts.en-us-large
      imagemagick
      inkscape
      libreoffice
      nextcloud-client
      okular
      pavucontrol
      pcmanfm
      pulseaudio
      scrot # used for screenshot in xournalpp
      signal-desktop
      sxiv
      vlc
      wireshark
      xclip
      xournalpp
      youtube-dl
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = associations;
    };
    # Home-manager activation fails because mimeapps.list already exists.
    # Trying a workarund.
    # https://github.com/nix-community/home-manager/issues/1213
    xdg.configFile."mimeapps.list".force = true;

    services.redshift = {
      enable = true;
      latitude = "51.18204";
      longitude = "13.81823";
    };

  };
}
