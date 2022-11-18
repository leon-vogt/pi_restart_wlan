ping 123.111.111.1 -c 1 -t 1 > /dev/null
if [ $? != 0 ]
then
  echo "==========================================" >> /home/pi/checkwifi.log
  echo "$(date +'%d.%m.%y %H:%M') - Keine Verbindung zu WLAN." >> /home/pi/checkwifi.log

  wlan_restart_counter=$(head -n 1 wlan_restart_counter.txt)
  if [ $wlan_restart_counter -ge 5 ]; then
    echo "Raspberry NEU STARTEN." >> /home/pi/checkwifi.log
    echo 0 > wlan_restart_counter.txt

    sudo /sbin/shutdown -r now
  else
    let wlan_restart_counter++
    echo "WLAN Adapter neu starten. (Versuch: $wlan_restart_counter)" >> /home/pi/checkwifi.log
    sudo ip link set wlan0 down
    sleep 5
    sudo ip link set wlan0 up
    
    echo $wlan_restart_counter > wlan_restart_counter.txt
  fi
  
  echo "==========================================" >> /home/pi/checkwifi.log
fi
