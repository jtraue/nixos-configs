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
          power-theme
          resurrect
        ];

      # select-layout even-vertical
      # or ctrl+b <space> to cycle through layouts
      extraConfig = ''
        # reload configuration
        bind R source-file ~/.config/tmux/tmux.conf \; display '~/tmux.conf sourced'

        set -g @tmux_power_theme 'gold'
        set -g @tmux_power_show_user    false
        set -g @tmux_power_show_host    false
        set -g @tmux_power_show_session    true
        run-shell "${pkgs.tmuxPlugins.power-theme}/share/tmux-plugins/power/tmux-power.tmux"

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
