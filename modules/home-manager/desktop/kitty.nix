{ config, lib, pkgs, ... }:

let
  cfg = config.home-modules.desktop.kitty;
  theme-light = ".config/kitty/solarized_light.conf";
  theme-dark = ".config/kitty/solarized_dark.conf";
  current-theme = ".config/kitty/mytheme";
in
{

  options.home-modules.desktop.kitty.enable = lib.mkEnableOption "Enables kitty.";

  config = lib.mkIf cfg.enable {

    # colors from https://github.com/dexpota/kitty-themes/blob/master/themes/Solarized_Light.conf
    home.file."${theme-light}".text = ''
      background            #fdf6e3
      foreground            #52676f
      cursor                #52676f
      selection_background  #e9e2cb
      color0 #e4e4e4
      color8 #ffffd7
      color1 #d70000
      color9 #d75f00
      color2 #5f8700
      color10 #585858
      color3 #af8700
      color11 #626262
      color4 #0087ff
      color12 #808080
      color5 #af005f
      color13 #5f5faf
      color6 #00afaf
      color14 #8a8a8a
      color7 #262626
      color15 #1c1c1c
      selection_foreground #fcf4dc
    '';

    home.file."${theme-dark}".text = ''
      background #001e26
      foreground #708183
      cursor #708183
      selection_background #002731
      color0 #002731
      color8 #001e26
      color1 #d01b24
      color9 #bd3612
      color2 #728905
      color10 #465a61
      color3 #a57705
      color11 #52676f
      color4 #2075c7
      color12 #708183
      color5 #c61b6e
      color13 #5856b9
      color6 #259185
      color14 #81908f
      color7 #e9e2cb
      color15 #fcf4dc
      selection_foreground #001e26
    '';

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
      };
      extraConfig = ''
        include $HOME/${current-theme}
      '';
    };

    programs.zsh.shellAliases = {
      kitty-light =
        "kitty @ set-colors -a -c $HOME/${theme-light}";
      kitty-dark =
        "kitty @ set-colors -a -c $HOME/${theme-dark}";
    };

  };
}
