alias forget='
    __OLDHISTSIZE=$HISTSIZE;
    export HISTSIZE=0;
    export HISTSIZE=$__OLDHISTSIZE;
    unset __OLDHISTSIZE;
    clear;
    if [[ "$TERM" =~ screen ]]; then
        screen -X scrollback 0;
        screen -X scrollback 10000;
    fi;
'
