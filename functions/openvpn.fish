function openvpn
    set -l openvpn_cmd sudo command openvpn $argv --script-security 2
    set -l files
    for event in $openvpn_events
        set -l file (mktemp -t openvpn-$event)
        set -a files $file
        set -l cmd echo \$\* \> $file
        set -a openvpn_cmd --$event (which sh)" --noprofile --norc -c '$cmd'"
    end
    nohup fish --private --command "openvpn-event-watcher $files" >/dev/null 2>&1 &
    function openvpn-cleanup -e openvpn-down
        # kill watcher and fswatch process
        kill -9 -$openvpn_watcher_pid
        # delete event files
        rm -f $files 2>/dev/null
    end
    $openvpn_cmd
end
