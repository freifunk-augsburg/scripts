#!/bin/sh

# This is a simple script that makes use of iwinfo to show the current signal 
# noise ratio (SNR) of an associated station on the four signal LEDs of a
# Ubiquiti NanoStation.

# Copyright (C) 2015 Michael Wendland
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.


IFACE='wlan0-1'                 # WiFi interface to monitor
ASSOC_MAC='6A:72:51:36:17:1E'   # MAC address of associated station to monitor
INTERVAL=3                      # Refresh interval in seconds


LEDS="ubnt:red:link1 ubnt:orange:link2 ubnt:green:link3 ubnt:green:link4"
SYSPATH="/sys/class/leds"


# Disable all triggers and turn off LEDs
for led in $LEDS
do
    echo "none" > $SYSPATH/$led/trigger
    echo "0"    > $SYSPATH/$led/brightness

    echo "disabled LED \"$led\""
done


toggle_leds() {
    i=0

    for led in $LEDS
    do
        if [ $i -lt $1 ]; then
            state=1
        else
            state=0
        fi

        echo $state > $SYSPATH/$led/brightness

        i=$((i+1))
    done
}


# Main loop, call iwinfo, parse SNR and toggle LEDs
while true
do

    snr=$(iwinfo $IFACE assoclist | grep $ASSOC_MAC | sed -r "s/.*\(SNR ([0-9]{1,2})\).*/\1/")

    if [ -z $snr ]; then
        snr=0
    fi

    echo "SNR: $snr"


	if   [ $snr -gt 30 ]; then
        toggle_leds 4
	elif [ $snr -gt 20 ]; then
        toggle_leds 3
	elif [ $snr -gt  5 ]; then
        toggle_leds 2
    else        
        toggle_leds 1
    fi


    sleep $INTERVAL

done
