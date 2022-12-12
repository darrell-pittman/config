#!/bin/bash

declare -r CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}"

declare -A dotfiles=(
[i3]="$CONFIG_DIR/i3/config"
[i3status]="$CONFIG_DIR/i3status/config"
[xinitrc]="$HOME/.xinitrc"
[bashrc]="$HOME/.bashrc"
[bash_aliases]="$HOME/.bash_aliases"
[profile]="$HOME/.profile"
[rofi]="$CONFIG_DIR/rofi/config.rasi"
[nvim]="$CONFIG_DIR/nvim/lua/wgc"
[fontconfig]="$CONFIG_DIR/fontconfig"
[redshift]="$CONFIG_DIR/redshift/redshift.conf"
[config]="$CONFIG_DIR")

if [ -z "$@" ]
then
  for k in ${!dotfiles[@]}
  do
    printf "%s\n" "$k"
  done | sort
else
  file=${dotfiles[$1]:-${1}}
  if [ -d "$file" ]
  then
    for f in $file/*
    do
      [ -e "$f" ] || continue
      printf "%s\n" "$f"
    done | sort
  else
    i3-msg 'exec i3-sensible-terminal -e "nvim '${file}'"' \
      1>/dev/null 2>&1
  fi
fi

