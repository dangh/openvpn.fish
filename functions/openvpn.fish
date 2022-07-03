function openvpn
  set --local openvpn_cmd sudo command openvpn $argv --script-security 2
  set --local files
  for event in $openvpn_events
    set --local file (mktemp -t openvpn-$event)
    set --append files $file
    set --local cmd echo \$\* \> $file
    set --append openvpn_cmd --$event (which sh)" --noprofile --norc -c '$cmd'"
  end
  nohup fish --private --command "openvpn-event-watcher $files" >/dev/null 2>&1 &
  function openvpn-cleanup --on-event openvpn-down
    # kill watcher and fswatch process
    kill -9 -$openvpn_watcher_pid
    # delete event files
    rm -f $files 2>/dev/null
  end
  $openvpn_cmd
end
