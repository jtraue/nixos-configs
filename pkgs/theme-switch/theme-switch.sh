#!/usr/bin/env bash


CURRENT_THEME=~/.color
VIMRC_COLOR_FILE=~/.vimrc.color
VIMRC_COLOR_FILE_TMP="${VIMRC_COLOR_FILE}.$$"
ROFI_COLOR_FILE=~/.rofi.theme
I3STATUS_COLOR_FILE=~/.i3status-color.toml

I3STATUS_PATH=$(dirname $(dirname "$(readlink -f $(which i3status-rs))"))

# mkdir -p $(dirname "$I3STATUS_COLOR_FILE")

# Determine mode
if grep --quiet --no-messages "light" "$CURRENT_THEME" ; then
    next_background=dark
else
    next_background=light
fi

# A specific mode (light/dark) can be forced from the command line
if [ -n "$1" ] && [ "$1" != "$next_background" ]; then
  # This is not that intuitive but if the requested mode is different from the
  # next mode then the _current_ mode is the same as the requested one and there
  # is nothing to do
    exit 0
fi

echo $next_background > "$CURRENT_THEME"

echo "next_background: $next_background"

# Rofi
if [ $next_background = dark ]; then
    echo "solarized" > "$ROFI_COLOR_FILE"
    ln -s --force "$I3STATUS_PATH/share/themes/solarized-dark.toml" "$I3STATUS_COLOR_FILE"
else
    echo "gruvbox-light" > "$ROFI_COLOR_FILE"
    ln -s --force "$I3STATUS_PATH/share/themes/solarized-light.toml" "$I3STATUS_COLOR_FILE"
fi


kitty +kitten themes --config-file-name mytheme --reload-in=all "Solarized $(echo $next_background | sed 's/./\U&/')"


# Update vim colors. Do this after changing terminal colors because the result
# is confusing otherwise (strangely looking colorscheme - not what I expect).
# Prevent vim from seing a partially changed file
cat>$VIMRC_COLOR_FILE_TMP<<EOF
set background=$next_background
EOF
mv "$VIMRC_COLOR_FILE_TMP" "$VIMRC_COLOR_FILE"

# i3status-rs does not yet react on reload, so use restart
i3-msg restart

