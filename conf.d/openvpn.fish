set --global openvpn_events \
  'up' \
  'tls-verify' \
  'ipchange' \
  'route-up' \
  'route-pre-down' \
  'down'

function openvpn-event-watcher
  set --universal openvpn_watcher_pid $fish_pid
  command fswatch -0 $argv | while read --null file
    set --local event
    string match --quiet --regex '/openvpn-(?<event>\w+)[^/]+$' $file
    set --local event_argv (cat $file | string collect)
    set --local var (string replace --all - _ openvpn-event-$event)
    set --universal $var $event_argv
  end
end

for event in $openvpn_events
  set --local var (string replace --all - _ openvpn-event-$event)
  function openvpn-event-emitter-$event --on-variable $var
    set --local event (status function | string replace openvpn-event-emitter- '')
    set --local var (string replace --all - _ openvpn-event-$event)
    emit openvpn-$event $$var
  end
end

function openvpn-event-debugger --argument-names action
  for event in $openvpn_events
    set --local funcname (status function)-$event
    set --local var (string replace --all - _ openvpn-event-$event)
    functions --erase $funcname
    if test "$action" != 'stop'
      if set --query $var
        echo previous event: $event
        set --show $var
        echo
      end
      function $funcname --on-event openvpn-$event
        set --local event (status function | string replace openvpn-event-debugger- '')
        echo openvpn event: $event
        set --show argv
        echo
      end
    end
  end
end
