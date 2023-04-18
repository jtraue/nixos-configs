{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.desktop.kitty;
  inherit (config.colorscheme) colors;
in
{

  options.home-modules.desktop.kitty.enable = lib.mkEnableOption "Enables kitty.";

  config = lib.mkIf cfg.enable {

    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.dejavu_fonts;
        name = "pango:DejaVu Sans Mono";
      };
      settings = {
        allow_remote_control = "yes";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
        font_size = 14;
        strip_trailing_spaces = "smart";
        enable_audio_bell = "no";
        term = "xterm-256color";
        macos_titlebar_color = "background";
        macos_option_as_alt = "yes";
        scrollback_lines = 10000;
        foreground = "#${colors.base05}";
        background = "#${colors.base00}";
        selection_background = "#${colors.base05}";
        selection_foreground = "#${colors.base00}";
        url_color = "#${colors.base04}";
        cursor = "#${colors.base05}";
        active_border_color = "#${colors.base03}";
        inactive_border_color = "#${colors.base01}";
        active_tab_background = "#${colors.base00}";
        active_tab_foreground = "#${colors.base05}";
        inactive_tab_background = "#${colors.base01}";
        inactive_tab_foreground = "#${colors.base04}";
        tab_bar_background = "#${colors.base01}";
        color0 = "#${colors.base00}";
        color1 = "#${colors.base08}";
        color2 = "#${colors.base0B}";
        color3 = "#${colors.base0A}";
        color4 = "#${colors.base0D}";
        color5 = "#${colors.base0E}";
        color6 = "#${colors.base0C}";
        color7 = "#${colors.base05}";
        color8 = "#${colors.base03}";
        color9 = "#${colors.base08}";
        color10 = "#${colors.base0B}";
        color11 = "#${colors.base0A}";
        color12 = "#${colors.base0D}";
        color13 = "#${colors.base0E}";
        color14 = "#${colors.base0C}";
        color15 = "#${colors.base07}";
        color16 = "#${colors.base09}";
        color17 = "#${colors.base0F}";
        color18 = "#${colors.base01}";
        color19 = "#${colors.base02}";
        color20 = "#${colors.base04}";
        color21 = "#${colors.base06}";
      };
    };
  };
}
