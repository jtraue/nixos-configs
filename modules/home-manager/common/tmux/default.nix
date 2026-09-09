{ config, lib, pkgs, ... }:

let
  cfg = config.my.common.tmux;
in
{

  options.my.common.tmux.enable = lib.mkEnableOption "Enables tmux.";

  config = lib.mkIf cfg.enable {

    # copy mode: ctrl+b [
    #            - select via vi keybindings
    #            - hit enter to confirm
    # paste: ctrl+b ]
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      baseIndex = 1;

      plugins = with pkgs.tmuxPlugins;
        [
          {
            plugin = catppuccin;
            extraConfig = ''
              set -g @catppuccin_flavor 'mocha' # latte, frappe, macchiato or mocha
              set -g @catppuccin_status_background 'none'
              set -g @catppuccin_date_time_text " W%V %Y-%m-%d %H:%M"

              # window list: number and application name
              # ('rounded' looks wrong here: its pill-shaped separators rely
              # on blending into a solid status-bar background color via a
              # reverse-video trick, but @catppuccin_status_background is
              # 'none' (transparent), so inactive windows get a mismatched
              # colored halo instead of a clean rounded cap)
              set -g @catppuccin_window_status_style 'basic'
              set -g @catppuccin_window_text " #{pane_current_command}"
              set -g @catppuccin_window_current_text " #{pane_current_command}"

              # user status module: person icon
              set -g @catppuccin_user_icon " "
            '';
          }
        ];

      # select-layout even-vertical
      # or ctrl+b <space> to cycle through layouts
      extraConfig = ''
        # reload configuration
        bind R source-file ~/.config/tmux/tmux.conf \; display '~/tmux.conf sourced'

        # window list: application name only, no number/flags
        set -g window-status-format "#[fg=#{@thm_overlay_2}] #{pane_current_command} "
        set -g window-status-current-format "#[fg=#{@thm_mauve},bold] #{pane_current_command} "

        # status bar: nothing on the left, only time/date on the right
        set -g status-left ""
        set -g status-right "#{E:@catppuccin_status_date_time}"

        bind q kill-session

        set-window-option -g xterm-keys on

        # enable mouse control (clockable windows, panes, resizable panes)
        set -g mouse on

        set -g default-terminal "xterm-256color" # colors!

        # split current window horizontally
        bind S split-window -v
        # split current window vertically
        bind | split-window -h

        # loud or quiet?
        set-option -g visual-activity off
        set-option -g visual-bell off
        set-option -g visual-silence off
        set-window-option -g monitor-activity off
        set-option -g bell-action none

        # Disable esc delay when switching modes in vim
        set -sg escape-time 0

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # nesting

        # Switch to inner tmux (Alt + Up)
        bind -n M-up send-keys M-F12

        # Switch to outer tmux (Alt + Down)
        bind -n M-up send-keys M-F11

        bind -n M-F12 \
            set -qg status-bg yellow \; \
            unbind -n S-left \; \
            unbind -n S-right \; \
            unbind -n S-C-left \; \
            unbind -n S-C-right \; \
            unbind -n C-t \; \
            set -qg prefix C-n

        bind -n M-F11 \
            set -qg status-bg black \; \
            bind -n S-left  prev \; \
            bind -n S-right next \; \
            bind -n S-C-left swap-window -t -1 \; \
            bind -n S-C-right swap-window -t +1 \; \
            bind -n C-t new-window -a -c "#{pane_current_path}" \; \
            set -qg prefix C-b
      '';

    };
  };
}
