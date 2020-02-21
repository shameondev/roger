#!/bin/bash

DIFF=$(diff /etc/crontab_save /etc/crontab)

cat /etc/crontab > /etc/crontab_save

if ["$DIFF" != ""]
then
	echo "Crontab changed, notifying admin."
	sendmail root@127.0.0.1 < /home/alouser/mail.txt
else
	echo "Crontab unchanged."
fi
