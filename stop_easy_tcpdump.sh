#!/bin/bash
#Checken, ob Benutzer root. Wenn nicht, also dieser ausführen.
if [ "$(id -u)" != "0" ]; then

    echo "Skript wird als root ausgeführt" 1>&2

    if [[ -f ~/bin/stop_easy_tcpdump.sh ]]
    then
        sudo mv ~/bin/stop_easy_tcpdump.sh /usr/local/bin/
    fi

    sudo /usr/local/bin/stop_easy_tcpdump.sh
exit 0
 fi
##################################################################

#suche alle mit etd ertsellten Dumps
TRACES=$(ps aux | grep "[e]asy_tcpdump" | awk '{print $22}' | cut -d"/" -f6)

echo -e "\e[93m
---Dieses Programm soll dabei helfen die mit easy_tcpdump.sh
---erstellten Dumps wieder zu stoppen---

\033[0m
"

echo -e "\e[95mWahle den Dump aus, den du stoppen möchtest.

\033[0m"

if [[ -z $TRACES ]]
then
    echo -e "\e[93m
    Es wurde kein Dump gefunden.

    \033[0m"
exit 5
else
    select TRACE in $TRACES
    do
        break
    done
fi

echo -e  "\e[94m$TRACE\e[93m wird gestoppt
\033[0m
"

systemctl stop $TRACE.service
systemctl disable $TRACE.service
systemctl status $TRACE.service | cat

rm /etc/systemd/system/$TRACE.service

exit 0
