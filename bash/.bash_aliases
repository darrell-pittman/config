alias vim='nvim'
alias ls='ls -p --hyperlink=auto --color=auto --group-directories-first'
alias ll='ls -la'
alias grep='grep --color=auto'

alias ds=lynx-google
alias ec='emacsclient -c -a ""'
#alias btc='bluetoothctl connect $(bluetoothctl devices|head -1|cut -d " " -f 2)'
alias btd='bluetoothctl disconnect'
alias rss='herd start redshift'
alias rsp='herd stop redshift'
alias pw='pipewire-start'
alias po='loginctl poweroff'

alias buds='btc buds'
alias dev-gimp='(source /opt/config/bash/gimp_vars; ${GIMP_PREFIX}/bin/gimp)'
alias svim='sudoedit'
alias sp='loginctl suspend'
alias newvim='NVIM_APPNAME=nvimnew nvim'
