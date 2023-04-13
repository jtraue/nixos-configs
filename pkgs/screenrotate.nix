{ pkgs, ... }:
let
  inherit (pkgs.xorg) xrandr;
  inherit (pkgs) xf86_input_wacom;
in
pkgs.writeShellScriptBin "screenrotate" ''
  set -eu

  display="eDP-1"
  touch="Wacom Pen and multitouch sensor Finger touch"
  stylus="Wacom Pen and multitouch sensor Pen stylus"
  eraser="Wacom Pen and multitouch sensor Pen eraser"

  rotation="$(${xrandr}/bin/xrandr -q --verbose | grep $display | egrep -o '\) (normal|left|inverted|right) \(' | egrep -o '(normal|left|inverted|right)')"

  case "$rotation" in
      normal)
        ${xrandr}/bin/xrandr --output "$display" --rotate left
        ${xf86_input_wacom}/bin/xsetwacom --set "$touch" Rotate ccw
        ${xf86_input_wacom}/bin/xsetwacom --set "$touch" Touch off
      ;;
      left)
        ${xrandr}/bin/xrandr --output "$display" --rotate normal
        ${xf86_input_wacom}/bin/xsetwacom --set "$touch" Rotate none
        ${xf86_input_wacom}/bin/xsetwacom --set "$touch" Touch on
      ;;
  esac
''
