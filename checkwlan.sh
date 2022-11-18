ping 123.111.111.1 -c 1 -t 1 > /dev/null
if [ $? != 0 ]
then
  echo "==========================================" >> checkwlan.log
  echo "$(date +'%d.%m.%y %H:%M') - Keine Verbindung zu WLAN." >> checkwlan.log
  wlan_restart_counter=$(head -n 1 wlan_restart_counter.txt)
  wlan_restart_counter=$((wlan_restart_counter+1))

  if [ $wlan_restart_counter -le 5 ]; then
    echo "WLAN Adapter neu starten. (Versuch: $wlan_restart_counter)" >> checkwlan.log
    sudo ip link set wlan0 down
    sleep 5
    sudo ip link set wlan0 up

    echo $wlan_restart_counter > wlan_restart_counter.txt
  else
    echo "Raspberry NEU STARTEN." >> checkwlan.log
    echo 0 > wlan_restart_counter.txt

    sudo /sbin/shutdown -r now
  fi

  echo "==========================================" >> checkwlan.log
fi