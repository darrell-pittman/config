


[ -d $HOME/bin ] && PATH=$HOME/bin:$PATH
[ -d $HOME/.local/bin ] && PATH=$HOME/.local/bin:$PATH

export PATH=`printf %s "$PATH" \
            | awk -v RS=: '{ if (!arr[$0]++) {printf("%s%s",!ln++?"":":",$0)}}'`


# Honor per-interactive-shell startup file
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

# export DRI_PRIME=1

. "$HOME/.cargo/env"

#if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
#  exec startx
#fi

