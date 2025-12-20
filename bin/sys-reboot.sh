#!/bin/bash

$HOME/bin/hypr-close-all-windows.sh
sleep 1 # Allow apps like Firefox to shutdown correctly
systemctl reboot --no-wall
