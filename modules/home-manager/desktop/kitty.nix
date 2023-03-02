{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.desktop.kitty;
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
        foreground = "#${config.colorScheme.colors.base05}";
        background = "#${config.colorScheme.colors.base00}";
      };
    };
  };
}
