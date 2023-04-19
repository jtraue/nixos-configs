{ pkgs, config, lib, ... }:

let
  cfg = config.home-modules.desktop.rofi;
  inherit (config.colorscheme) colors;
in
{

  options.home-modules.desktop.rofi.enable = lib.mkEnableOption "Enables rofi.";

  config = lib.mkIf cfg.enable {

    programs.rofi = {
      enable = true;
      terminal = "kitty";
      theme =
        let
          inherit (config.lib.formats.rasi) mkLiteral;
        in
        {
          "*" = {
            red = mkLiteral "#${colors.base08}";
            blue = mkLiteral "#${colors.base0D}";
            lightfg = mkLiteral "#${colors.base06}";
            lightbg = mkLiteral "#${colors.base01}";
            foreground = mkLiteral "#${colors.base05}";
            background = mkLiteral "#${colors.base00}";
            background-color = mkLiteral "#${colors.base00}";
            separatorcolor = mkLiteral "@foreground";
            border-color = mkLiteral "@foreground";
            selected-normal-foreground = mkLiteral "@lightbg";
            selected-normal-background = mkLiteral "@lightfg";
            selected-active-foreground = mkLiteral "@background";
            selected-active-background = mkLiteral "@blue";
            selected-urgent-foreground = mkLiteral "@background";
            selected-urgent-background = mkLiteral "@red";
            normal-foreground = mkLiteral "@foreground";
            normal-background = mkLiteral "@background";
            active-foreground = mkLiteral "@background";
            active-background = mkLiteral "@foreground";
            urgent-foreground = mkLiteral "@red";
            urgent-background = mkLiteral "@background";
            alternate-normal-foreground = mkLiteral "@foreground";
            alternate-normal-background = mkLiteral "@lightbg";
            alternate-active-foreground = mkLiteral "@blue";
            alternate-active-background = mkLiteral "@lightbg";
            alternate-urgent-foreground = mkLiteral "@red";
            alternate-urgent-background = mkLiteral "@lightbg";
          };
        };

      pass = {
        enable = true;
        stores = [ "~/.password-store" ];
      };
    };
  };
}
