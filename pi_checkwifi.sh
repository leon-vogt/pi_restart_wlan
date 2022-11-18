#!/bin/bash

# This file creates a script that checks if the wifi is connected and if not, it will try to reconnect it.
# If it could not reconnect for X times, it will reboot the pi.
# This script is called by the crontab every 1 minute.

current_gateway_ip="awk '\$1 == \"0.0.0.0\" { print \$2 }'"
wlan_interface="wlan0"
max_ping_attempts=1
ping_timeout=1

script_file="checkwifi.sh"
log_file="checkwifi.log"
wlan_restart_counter_file="wlan_restart_counter.txt"

# Create the effective script and save it in the checkwifi.sh file
touch $script_file
echo "ping 123.111.111.1 -c $max_ping_attempts -t $ping_timeout > /dev/null
if [ \$? != 0 ]
then
  echo \"==========================================\" >> $log_file
  echo \"\$(date +'%d.%m.%y %H:%M') - Keine Verbindung zu WLAN.\" >> $log_file
  wlan_restart_counter=\$(head -n 1 $wlan_restart_counter_file)

  if [ \$wlan_restart_counter -le 5 ]; then
    wlan_restart_counter=\$((wlan_restart_counter+1))
    echo \"WLAN Adapter neu starten. (Versuch: \$wlan_restart_counter)\" >> $log_file
    sudo ip link set $wlan_interface down
    sleep 5
    sudo ip link set $wlan_interface up
    
    echo \$wlan_restart_counter > $wlan_restart_counter_file
  else
    echo \"Raspberry NEU STARTEN.\" >> $log_file
    echo 0 > $wlan_restart_counter_file

    sudo /sbin/shutdown -r now
  fi
  
  echo \"==========================================\" >> $log_file
fi" > $script_file
chmod +x $script_file

# Create an initial wlan_restart_counter file
echo 0 > $wlan_restart_counter_file

# Create initial log file
touch $log_file

# ADD THE SCRIPT TO THE CRONTAB (have to run as sudo to be able to reboot the pi)
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/sudo -H /home/pi/checkwifi.sh >> /dev/null 2>&1") | crontab -



######### EFFIKTIVER GATEWAY CHECK #########
# echo "route -n | $current_gateway_ip | xargs ping -c $max_ping_attempts -t $ping_timeout > /dev/null
#############################################