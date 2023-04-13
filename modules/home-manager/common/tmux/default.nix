{ config, lib, ... }:

let
  cfg = config.home-modules.common.tmux;
in
{

  options.home-modules.common.tmux.enable = lib.mkEnableOption "Enables tmux.";

  config = lib.mkIf cfg.enable {

    xdg.configFile = {
      "tmuxinator/particle.yml".source = ./particle.yml;
      "tmuxinator/svp.yml".source = ./svp.yml;
      "tmuxinator/passthrough.yml".source = ./passthrough.yml;
    };

    # copy mode: ctrl+b [
    #            - select via vi keybindings
    #            - hit enter to confirm
    # paste: ctrl+b ]
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      baseIndex = 1;

      tmuxinator.enable = true;

      # select-layout even-vertical
      # or ctrl+b <space> to cycle through layouts
      extraConfig = ''
        # reload configuration
        bind r source-file ~/.tmux.conf \; display '~/.tmux.conf sourced'

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

        ##########
        # Design #
        ##########

        # --- colors (solarized dark)
        # default statusbar colors
        set -g status-style bg=black,fg=yellow

        # default window title colors
        setw -g window-status-style fg=brightblue,bg=default

        # active window title colors
        setw -g window-status-current-style fg=yellow,bg=default,dim

        # pane border
        set -g pane-border-style fg=black,bg=default

        # command line/message text
        set -g message-style fg=yellow,bg=black

        # pane number display
        set -g display-panes-active-colour yellow
        set -g display-panes-colour brightblue

        # clock
        setw -g clock-mode-colour yellow

        tmux_conf_theme_left_separator_main='\uE0B0'
        tmux_conf_theme_left_separator_sub='\uE0B1'
        tmux_conf_theme_right_separator_main='\uE0B2'
        tmux_conf_theme_right_separator_sub='\uE0B3'

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
