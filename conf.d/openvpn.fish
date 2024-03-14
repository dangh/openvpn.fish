set -g openvpn_events \
    up \
    tls-verify \
    ipchange \
    route-up \
    route-pre-down \
    down

function openvpn-event-watcher
    set -U openvpn_watcher_pid $fish_pid
    command fswatch -0 $argv | while read -z file
        set -l event
        string match -q -r '/openvpn-(?<event>\w+)[^/]+$' $file
        set -l event_argv (cat $file | string collect)
        set -l var (string replace -a - _0 openvpn-event-$event)
        set -U $var $event_argv
    end
end

for event in $openvpn_events
    set -l var (string replace -a - _0 openvpn-event-$event)
    function openvpn-event-emitter-$event -v $var
        set -l event (status function | string replace openvpn-event-emitter- '')
        set -l var (string replace -a - _0 openvpn-event-$event)
        emit openvpn-$event $$var
    end
end

function openvpn-event-debugger -a action
    for event in $openvpn_events
        set -l funcname (status function)-$event
        set -l var (string replace -a - _0 openvpn-event-$event)
        functions -e $funcname
        if test "$action" != stop
            if set -q $var
                echo previous event: $event
                set -S $var
                echo
            end
            function $funcname -e openvpn-$event
                set -l event (status function | string replace openvpn-event-debugger- '')
                echo openvpn event: $event
                set -S argv
                echo
            end
        end
    end
end
