#!/bin/bash

# This file creates a script that checks if the wlan is connected if not, it will try to reconnect it.
# If it could not reconnect for X times, it will reboot the pi.
# This script is called by the crontab every 1 minute.

current_gateway_ip="awk '\$1 == \"0.0.0.0\" { print \$2 }'"
wlan_interface="wlan0"
max_ping_attempts=4
ping_timeout=2

max_wlan_restart_attempts=5

script_file="checkwlan.sh"
log_file="checkwlan.log"
wlan_restart_counter_file="wlan_restart_counter.txt"

# Create the effective script and save it in the checkwlan.sh file
touch $script_file
echo "route -n | $current_gateway_ip | xargs ping -c $max_ping_attempts -t $ping_timeout > /dev/null
if [ \$? != 0 ]
then
  echo \"==========================================\" >> $log_file
  echo \"\$(date +'%d.%m.%y %H:%M') - Keine Verbindung zu WLAN.\" >> $log_file
  wlan_restart_counter=\$(head -n 1 $wlan_restart_counter_file)
  wlan_restart_counter=\$((wlan_restart_counter+1))

  if [ \$wlan_restart_counter -le $max_wlan_restart_attempts ]; then
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

# Remove script from crontab (if it is already there)
(crontab -l 2>/dev/null | grep -v "/home/pi/$script_file") | crontab -

# Add script to crontab (have to run as sudo to be able to reboot the pi)
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/sudo -H /home/pi/$script_file >> /dev/null 2>&1") | crontab -