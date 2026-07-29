{ config, lib, pkgs, ... }:

let
  cfg = config.my.desktop.gnome;
in
{

  options.my.desktop.gnome.enable = lib.mkEnableOption "Enables gnome.";

  config = lib.mkIf cfg.enable {
    dconf = {
      enable = true;
      settings = with lib.hm.gvariant; {

        # --- Console ---
        "org/gnome/Console" = {
          font-scale = 1.4;
          theme = "night";
        };

        # --- Interface ---
        "org/gnome/desktop/interface" = {
          color-scheme = "default";
          gtk-theme = "gruvbox-light-soft";
          show-battery-percentage = true;
          gtk-enable-primary-paste = true;
          toolkit-accessibility = false;
        };

        # --- Input ---
        "org/gnome/desktop/input-sources" = {
          sources = [ (mkTuple [ "xkb" "us+intl" ]) ];
        };

        # --- Peripherals: touchpad disabled, using trackpoint instead ---
        "org/gnome/desktop/peripherals/touchpad" = {
          send-events = "disabled";
          two-finger-scrolling-enabled = true;
        };

        # --- Window Manager Preferences ---
        "org/gnome/desktop/wm/preferences" = {
          auto-raise = false;
          focus-mode = "mouse";
          num-workspaces = 5;
          workspace-names = [ "" "" "mail" "org" "chat" ];
        };

        # --- Window Manager Keybindings ---
        "org/gnome/desktop/wm/keybindings" = {
          # Workspace switching
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          switch-to-workspace-5 = [ "<Super>5" ];
          switch-to-workspace-left = [ "<Super>Page_Up" "<Super><Alt>Left" "<Control><Alt>Left" ];
          switch-to-workspace-right = [ "<Super>Page_Down" "<Super><Alt>Right" "<Control><Alt>Right" ];
          switch-to-workspace-last = [ "<Super>End" ];

          # Move windows to workspaces
          move-to-workspace-1 = [ "<Shift><Super>1" ];
          move-to-workspace-2 = [ "<Shift><Super>2" ];
          move-to-workspace-3 = [ "<Shift><Super>3" ];
          move-to-workspace-4 = [ "<Shift><Super>4" ];
          move-to-workspace-5 = [ "<Shift><Super>5" ];
          move-to-workspace-left = [ "<Super><Shift>Page_Up" "<Super><Shift><Alt>Left" "<Control><Shift><Alt>Left" ];
          move-to-workspace-right = [ "<Super><Shift>Page_Down" "<Super><Shift><Alt>Right" "<Control><Shift><Alt>Right" ];

          # Window tiling
          maximize = [ "<Super>Up" ];
          unmaximize = [ "<Super>Down" "<Alt>F5" ];

          # Move to monitor
          move-to-monitor-left = [ "<Shift><Super>Left" ];
          move-to-monitor-right = [ "<Shift><Super>Right" ];
          move-to-monitor-up = [ "<Super><Shift>Up" ];
          move-to-monitor-down = [ "<Super><Shift>Down" ];

          # Use switch-windows instead of switch-applications
          switch-applications = [ ];
          switch-applications-backward = [ ];
          switch-windows = [ "<Alt>Tab" ];
          switch-windows-backward = [ "<Shift><Alt>Tab" ];
        };

        # --- Mutter ---
        "org/gnome/mutter" = {
          dynamic-workspaces = false;
          edge-tiling = true;
          workspaces-only-on-primary = true;
        };

        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [ "<Super>Left" ];
          toggle-tiled-right = [ "<Super>Right" ];
        };

        # --- Media Keys ---
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          ];
          screensaver = [ "<Super>q" ];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>Return";
          name = "terminal";
          command = "kgx -- tmux";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Shift><Control>p";
          name = "1password";
          command = "1password --quick-access";
        };

        # --- Shell ---
        "org/gnome/shell" = {
          disable-user-extensions = false;
          disabled-extensions = [ "paperwm@paperwm.github.com" ];
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "batime@martin.zurowietz.de"
            "caffeine@patapon.info"
            "emoji-copy@felipeftn"
            "Move_Clock@rmy.pobox.com"
            "space-bar@luchrioh"
            "tailscale-status@maxgallup.github.com"
            "top-bar-organizer@julian.gse.jsts.xyz"
            "trayIconsReloaded@selfmade.pl"
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "Vitals@CoreCoding.com"
          ];
          favorite-apps = [
            "nemo.desktop"
            "org.gnome.Evolution.desktop"
            "chromium-browser.desktop"
          ];
        };

        "org/gnome/shell/app-switcher" = {
          current-workspace-only = true;
        };

        "org/gnome/shell/keybindings" = {
          focus-active-notification = [ "<Super>n" ];
          # Disable switch-to-application to free up Super+1-4 for workspaces
          switch-to-application-1 = [ ];
          switch-to-application-2 = [ ];
          switch-to-application-3 = [ ];
          switch-to-application-4 = [ ];
        };

        # --- Extension: Auto Move Windows ---
        "org/gnome/shell/extensions/auto-move-windows" = {
          application-list = [
            "element-desktop.desktop:5"
            "1password.desktop:5"
            "org.gnome.Evolution.desktop:3"
            "super-productivity.desktop:4"
          ];
        };

        # --- Extension: Caffeine ---
        "org/gnome/shell/extensions/caffeine" = {
          show-indicator = "always";
        };

        # --- Extension: Tray Icons Reloaded ---
        "org/gnome/shell/extensions/trayIconsReloaded" = {
          icon-size = 16;
          icons-limit = 10;
        };

        # --- Extension: Space Bar ---
        "org/gnome/shell/extensions/space-bar/behavior" = {
          always-show-numbers = true;
          enable-custom-label = false;
        };

        "org/gnome/shell/extensions/space-bar/shortcuts" = {
          enable-move-to-workspace-shortcuts = true;
        };

        "org/gnome/shell/extensions/space-bar/appearance" = {
          application-styles = ''
            .space-bar {
              -natural-hpadding: 12px;
            }

            .space-bar-workspace-label.active {
              margin: 0 4px;
              background-color: rgba(255,255,255,0.3);
              color: rgba(255,255,255,1);
              border-color: rgba(0,0,0,0);
              font-weight: 700;
              border-radius: 4px;
              border-width: 0px;
              padding: 3px 8px;
            }

            .space-bar-workspace-label.inactive {
              margin: 0 4px;
              background-color: rgba(0,0,0,0);
              color: rgba(255,255,255,1);
              border-color: rgba(0,0,0,0);
              font-weight: 700;
              border-radius: 4px;
              border-width: 0px;
              padding: 3px 8px;
            }

            .space-bar-workspace-label.inactive.empty {
              margin: 0 4px;
              background-color: rgba(0,0,0,0);
              color: rgba(255,255,255,0.5);
              border-color: rgba(0,0,0,0);
              font-weight: 700;
              border-radius: 4px;
              border-width: 0px;
              padding: 3px 8px;
            }
          '';
        };

        # --- Extension: Top Bar Organizer ---
        "org/gnome/shell/extensions/top-bar-organizer" = {
          left-box-order = [ "activities" "WorkspaceMenu" "FocusButton" "OpenPositionButton" "Space Bar" ];
          right-box-order = [
            "appindicator-kstatusnotifieritem-superProductivity_status_icon_1"
            "appindicator-kstatusnotifieritem-Element_status_icon_1"
            "appindicator-kstatusnotifieritem-Vorta"
            "appindicator-kstatusnotifieritem-chrome_status_icon_1"
            "TrayIconsReloaded"
            "vitalsMenu"
            "emoji-copy@felipeftn"
            "tailscale"
            "appindicator-kstatusnotifieritem-udiskie"
            "appindicator-kstatusnotifieritem-blueman"
            "appindicator-kstatusnotifieritem-Nextcloud"
            "screenRecording"
            "appindicator-kstatusnotifieritem-nm-applet"
            "screenSharing"
            "dwellClick"
            "a11y"
            "keyboard"
            "dateMenu"
            "quickSettings"
          ];
        };

        # --- Nautilus ---
        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "list-view";
          search-view = "list-view";
        };

        "org/gnome/nautilus/icon-view" = {
          default-zoom-level = "extra-large";
        };

        "org/gnome/nautilus/compression" = {
          default-compression-format = "encrypted_zip";
        };

        # --- Nemo ---
        "org/nemo/preferences" = {
          default-folder-viewer = "list-view";
          date-format = "iso";
          date-font-choice = "no-mono";
          show-open-in-terminal-toolbar = true;
          show-home-icon-toolbar = false;
          show-full-path-titles = false;
          show-advanced-permissions = false;
        };

      };
    };
  };
}
