#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi


# Disable DPMS turning off the screen
xset -dpms
xset s off

# Disable bell
xset -b

# Enable zapping (C-A-<Bksp> kills X)
setxkbmap -option terminate:ctrl_alt_bksp

# Enforce correct locales from the beginning:
# LC_ALL is unset since it overwrites everything
# LANG=de_DE.UTF-8 is used, except for:
# LC_MESSAGES=C never translates program output
# LC_TIME=en_DK leads to yyyy-mm-dd hh:mm date/time output
unset LC_ALL
export LANG=en_CA.UTF-8
export LC_MESSAGES=C
export LC_TIME=en_CA.UTF-8

# Use XToolkit in java applications
export AWT_TOOLKIT=XToolkit

# Set background color
xsetroot -solid "#333333"

# Enable core dumps in case something goes wrong
ulimit -c unlimited


. $HOME/bin/gimp_pixel_art
$HOME/bin/display.sh external

/usr/bin/numlockx
/usr/bin/xscreensaver --no-splash &
/usr/bin/xss-lock --ignore-sleep -- xscreensaver-command -lock &


# Start i3 and log to ~/.i3/logfile
echo "Starting at $(date)" > ~/.i3/logfile
/usr/bin/i3 -V -d all >> ~/.i3/logfile 
/usr/bin/pkill -9 redshift
/usr/bin/pkill -9 pipewire


