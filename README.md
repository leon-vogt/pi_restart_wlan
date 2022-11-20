# Check WLan Status

## Install

```
curl -o- https://raw.githubusercontent.com/leon-vogt/pi_restart_wlan/main/checkwlan_script_generator.sh | bash
```

## About
The [checkwlan_script_generator.sh](./checkwlan_script_generator.sh) creates a script that checks if the wlan is connected if not, it will try to reconnect it.
If it could not reconnect for X times, it will reboot the pi.  

The reason why the script is beeing generated, is so the only thing you have to do is run the script on the pi.  
The script will add itself to the crontab and create the necessary files.
