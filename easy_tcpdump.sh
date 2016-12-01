#!/bin/bash

#################################
#Befehlsvariablen
DUMPORDNER=~/Traces/easy_tcpdump
TCPDUMP=/usr/sbin/tcpdump
#################################
#Checken, ob Benutzer root. Wenn nicht, also dieser ausführen.
 if [ "$(id -u)" != "0" ]; then

        echo "Skript wird als root ausgeführt" 1>&2
        if [[ -f ~/bin/easy_tcpdump.sh ]]
then
   sudo mv ~/bin/easy_tcpdump.sh /usr/local/bin/
fi

        sudo /usr/local/bin/easy_tcpdump.sh

exit 1
 fi

if [ ! -d $DUMPORDNER ]
 then

        mkdir -p "$DUMPORDNER"
        echo "Ordner $DUMPORDNER ertellt"
 fi

echo -e "\e[93m
---Dieses Programm soll dabei helfen einfache tcpdumps zu erstellen.---
---Die Dateien werden in \e[94m$DUMPORDNER\e[93m abgelegt.---

\033[0m
"

echo -e "Benenne deinen Dump
"
        read DUMPNAME

echo -e "\e[95mWaehle das interface
\e[92meth1 \e[95m
"

mkdir $DUMPORDNER/$DUMPNAME
DUMPORDNER=$DUMPORDNER/$DUMPNAME


select INTERFACE in $(ls /sys/class/net/)
 do
        break
 done

echo "Gib eine oder mehrere host IP Adressen an (Leerzeichen als Trenner)
"
        read IPS

#Erstellt Variable WOC, in der die aus Variable IPS gespeicherten Elemente gezält werden
WOC=$(echo $IPS | wc -w)
#Rechnet Variable WOC um +1. Wichtig für die spatere for Schleife und die darin enthaltene if Bedingung.
WC=$((WOC+1))

#erstellt leeres Array, das in der Folgenden Schleife gefüllt wird.
IP=()
for ((i=1;i<"$WC"; i++))
 do

#Bedingung pruft, ob es sich um die letzte Stelle im Array handelt. (WOC wird wieder gebraucht.)
        if [[ "$i" < $WOC ]]; then

#IP[i] erstellt eine Position "i" in dem Array
#Diese Position wird mit dem Wert hinter dem = gefüllt.
                IP[i]="host $(echo $IPS | cut -d" " -f$i) or "
         else

                IP[i]="host $(echo $IPS | cut -d" " -f$i)"
         fi

 done

COMMAND="$TCPDUMP -n -i $INTERFACE -s 0 -W 20 -C 50 -w $DUMPORDNER/$DUMPNAME `printf '%s' "${IP[@]}"`"



echo "moechtest du den Dump als Daemon starten?
"
select DAEMON in Ja Nein
 do
        break
 done

if [[ $DAEMON == [jJ]a ]]
 then

        touch /etc/systemd/system/$DUMPNAME.service
        chmod 755 /etc/systemd/system/$DUMPNAME.service
        ######################
        echo "[Unit]
Description=$DUMPNAME

[Service]
ExecStart=/usr/bin/nohup $COMMAND
Restart=on-abort
SuccessExitStatus=9 15 SIGKILL SIGTERM

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$DUMPNAME.service
        #####################
        systemctl status $DUMPNAME.service
        systemctl enable $DUMPNAME.service
        systemctl status $DUMPNAME.service
        systemctl start $DUMPNAME.service
        systemctl status $DUMPNAME.service
 else
        $COMMAND
 fi

exit 0
