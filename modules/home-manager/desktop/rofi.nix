{ pkgs, config, lib, ... }:

let
  cfg = config.home-modules.desktop.rofi;
in
{

  options.home-modules.desktop.rofi.enable = lib.mkEnableOption "Enables rofi.";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      rofi
    ];

    home.file.".config/rofi/config.rasi".text = ''
      configuration {
      modi: "window,run,ssh";
      /*  width: 50;*/
      /*  lines: 15;*/
      /*  columns: 1;*/
      /*  font: "mono 12";*/
      /*  bw: 1;*/
      /*  location: 0;*/
      /*  padding: 5;*/
      /*  yoffset: 0;*/
      /*  xoffset: 0;*/
      /*  fixed-num-lines: true;*/
      /*  show-icons: false;*/
      terminal: "kitty";
      /*  ssh-client: "ssh";*/
      /*  ssh-command: "{terminal} -e {ssh-client} {host} [-p {port}]";*/
      /*  run-command: "{cmd}";*/
      /*  run-list-command: "";*/
      /*  run-shell-command: "{terminal} -e {cmd}";*/
      /*  window-command: "wmctrl -i -R {window}";*/
      /*  window-match-fields: "all";*/
      /*  icon-theme: ;*/
      /*  drun-match-fields: "name,generic,exec,categories";*/
      /*  drun-show-actions: false;*/
      /*  drun-display-format: "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";*/
      /*  disable-history: false;*/
      /*  ignored-prefixes: "";*/
      /*  sort: false;*/
      /*  sorting-method: ;*/
      /*  case-sensitive: false;*/
      /*  cycle: true;*/
      /*  sidebar-mode: false;*/
      /*  eh: 1;*/
      /*  auto-select: false;*/
      /*  parse-hosts: false;*/
      /*  parse-known-hosts: true;*/
      /*  combi-modi: "window,run";*/
      /*  matching: "normal";*/
      /*  tokenize: true;*/
      /*  m: "-5";*/
      /*  line-margin: 2;*/
      /*  line-padding: 1;*/
      /*  filter: ;*/
      /*  separator-style: "dash";*/
      /*  hide-scrollbar: false;*/
      /*  fullscreen: false;*/
      /*  fake-transparency: false;*/
      /*  dpi: -1;*/
      /*  threads: 0;*/
      /*  scrollbar-width: 8;*/
      /*  scroll-method: 0;*/
      /*  fake-background: "screenshot";*/
      /*  window-format: "{w}    {c}   {t}";*/
      /*  click-to-exit: true;*/
      /*  show-match: true;*/
      /*  color-normal: ;*/
      /*  color-urgent: ;*/
      /*  color-active: ;*/
      /*  color-window: ;*/
      /*  max-history-size: 25;*/
      /*  combi-hide-mode-prefix: false;*/
      /*  matching-negate-char: '-' /* unsupported */;*/
      /*  cache-dir: ;*/
      /*  pid: "/run/user/1000/rofi.pid";*/
      /*  display-window: ;*/
      /*  display-windowcd: ;*/
      /*  display-run: ;*/
      /*  display-ssh: ;*/
      /*  display-drun: ;*/
      /*  display-combi: ;*/
      /*  display-keys: ;*/
      /*  kb-primary-paste: "Control+V,Shift+Insert";*/
      /*  kb-secondary-paste: "Control+v,Insert";*/
      /*  kb-clear-line: "Control+w";*/
      /*  kb-move-front: "Control+a";*/
      /*  kb-move-end: "Control+e";*/
      /*  kb-move-word-back: "Alt+b,Control+Left";*/
      /*  kb-move-word-forward: "Alt+f,Control+Right";*/
      /*  kb-move-char-back: "Left,Control+b";*/
      /*  kb-move-char-forward: "Right,Control+f";*/
      /*  kb-remove-word-back: "Control+Alt+h,Control+BackSpace";*/
      /*  kb-remove-word-forward: "Control+Alt+d";*/
      /*  kb-remove-char-forward: "Delete,Control+d";*/
      /*  kb-remove-char-back: "BackSpace,Shift+BackSpace,Control+h";*/
      /*  kb-remove-to-eol: "Control+k";*/
      /*  kb-remove-to-sol: "Control+u";*/
      /*  kb-accept-entry: "Control+j,Control+m,Return,KP_Enter";*/
      /*  kb-accept-custom: "Control+Return";*/
      /*  kb-accept-alt: "Shift+Return";*/
      /*  kb-delete-entry: "Shift+Delete";*/
      /*  kb-mode-next: "Shift+Right,Control+Tab";*/
      /*  kb-mode-previous: "Shift+Left,Control+ISO_Left_Tab";*/
      /*  kb-row-left: "Control+Page_Up";*/
      /*  kb-row-right: "Control+Page_Down";*/
      /*  kb-row-up: "Up,Control+p,ISO_Left_Tab";*/
      /*  kb-row-down: "Down,Control+n";*/
      /*  kb-row-tab: "Tab";*/
      /*  kb-page-prev: "Page_Up";*/
      /*  kb-page-next: "Page_Down";*/
      /*  kb-row-first: "Home,KP_Home";*/
      /*  kb-row-last: "End,KP_End";*/
      /*  kb-row-select: "Control+space";*/
      /*  kb-screenshot: "Alt+S";*/
      /*  kb-ellipsize: "Alt+period";*/
      /*  kb-toggle-case-sensitivity: "grave,dead_grave";*/
      /*  kb-toggle-sort: "Alt+grave";*/
      /*  kb-cancel: "Escape,Control+g,Control+bracketleft";*/
      /*  kb-custom-1: "Alt+1";*/
      /*  kb-custom-2: "Alt+2";*/
      /*  kb-custom-3: "Alt+3";*/
      /*  kb-custom-4: "Alt+4";*/
      /*  kb-custom-5: "Alt+5";*/
      /*  kb-custom-6: "Alt+6";*/
      /*  kb-custom-7: "Alt+7";*/
      /*  kb-custom-8: "Alt+8";*/
      /*  kb-custom-9: "Alt+9";*/
      /*  kb-custom-10: "Alt+0";*/
      /*  kb-custom-11: "Alt+exclam";*/
      /*  kb-custom-12: "Alt+at";*/
      /*  kb-custom-13: "Alt+numbersign";*/
      /*  kb-custom-14: "Alt+dollar";*/
      /*  kb-custom-15: "Alt+percent";*/
      /*  kb-custom-16: "Alt+dead_circumflex";*/
      /*  kb-custom-17: "Alt+ampersand";*/
      /*  kb-custom-18: "Alt+asterisk";*/
      /*  kb-custom-19: "Alt+parenleft";*/
      /*  kb-select-1: "Super+1";*/
      /*  kb-select-2: "Super+2";*/
      /*  kb-select-3: "Super+3";*/
      /*  kb-select-4: "Super+4";*/
      /*  kb-select-5: "Super+5";*/
      /*  kb-select-6: "Super+6";*/
      /*  kb-select-7: "Super+7";*/
      /*  kb-select-8: "Super+8";*/
      /*  kb-select-9: "Super+9";*/
      /*  kb-select-10: "Super+0";*/
      /*  ml-row-left: "ScrollLeft";*/
      /*  ml-row-right: "ScrollRight";*/
      /*  ml-row-up: "ScrollUp";*/
      /*  ml-row-down: "ScrollDown";*/
      /*  me-select-entry: "MousePrimary";*/
      /*  me-accept-entry: "MouseDPrimary";*/
      /*  me-accept-custom: "Control+MouseDPrimary";*/
      }
      @theme "${pkgs.rofi}/share/rofi/themes/solarized.rasi"
    '';

    home.file.".config/rofi-pass/config".text = ''
      # permanently set alternative root dir. Use ":" to separate multiple roots
      # which can be switched at runtime with shift+left/right
      root=~/.password-store:~/conf/admin/admin-secrets

      # rofi command. Make sure to have "$@" as last argument
      _rofi () {
          rofi -i -no-auto-select "$@"
      }

      # default command to generate passwords
      _pwgen () {
        pwgen -y "$@"
      }

      # image viewer to display qrcode of selected entry
      # qrencode is needed to generate the image and a viewer
      # that can read from pipes. Known viewers to work are feh and display
      _image_viewer () {
          feh -
      #    display
      }

      # It is possible to use wl-copy and wl-paste from wl-clipboard
      # Just uncomment the lines with wl-copy and wl-paste
      # and comment the xclip lines
      #
      _clip_in_primary() {
        xclip
        # wl-copy-p
      }

      _clip_in_clipboard() {
        xclip -selection clipboard
        # wl-copy
      }

      _clip_out_primary() {
        xclip -o
        # wl-paste -p
      }

      _clip_out_clipboard() {
        xclip --selection clipboard -o
        # wl-paste
      }


      # xdotool needs the keyboard layout to be set using setxkbmap
      # You can do this in your autostart scripts (e.g. xinitrc)

      # If for some reason, you cannot do this, you can set the command here.
      # and set fix_layout to true
      fix_layout=false

      layout_cmd () {
        setxkbmap us
      }

      # fields to be used
      URL_field='url'
      USERNAME_field='user'
      AUTOTYPE_field='autotype'

      # delay to be used for :delay keyword
      delay=2

      # rofi-pass needs to close itself before it can type passwords. Set delay here.
      wait=0.2

      # delay between keypresses when typing (in ms)
      xdotool_delay=12

      ## Programs to be used
      # Editor
      EDITOR='gvim -f'

      # Browser
      BROWSER='xdg-open'

      ## Misc settings

      default_do='copyPass' # menu, autotype, copyPass, typeUser, typePass, copyUser, copyUrl, viewEntry, typeMenu, actionMenu, copyMenu, openUrl
      auto_enter='false'
      notify='false'
      default_autotype='pass:tab user'

      # color of the help messages
      # leave empty for autodetection
      help_color="#4872FF"

      # Clipboard settings
      # Possible options: primary, clipboard, both
      clip=both

      # Seconds before clearing pass from clipboard
      clip_clear=45

      ## Options for generating new password entries

      # open new password entries in editor
      edit_new_pass="true"

      # default_user is also used for password files that have no user field.
      #default_user="''${ROFI_PASS_DEFAULT_USER-$(whoami)}"
      #default_user2=mary_ann
      #password_length=12

      # Custom Keybindings
      autotype="Alt+1"
      type_user="Alt+2"
      type_pass="Alt+3"
      open_url="Alt+4"
      copy_name="Alt+u"
      copy_url="Alt+l"
      copy_pass="Alt+p"
      show="Alt+o"
      copy_entry="Alt+2"
      type_entry="Alt+1"
      copy_menu="Alt+c"
      action_menu="Alt+a"
      type_menu="Alt+t"
      help="Alt+h"
      switch="Alt+x"
      insert_pass="Alt+n"
    '';
  };
}
