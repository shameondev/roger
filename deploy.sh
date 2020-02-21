#!/bin/bash

# getting system updates
apt-get update -y
apt-get upgrade -y
apt-get install sudo vim portsentry ufw fail2ban apache2 mailtils git ntp -y

# making alouser sudoer
adduser --disabled-password --gecos "" alouser
rm -rf /etc/sudoers
cp /root/deploy/src/sudoers /etc/

# set timezone
timedatectl set-timezone Europe/Moscow

# configure static ip
fm -rf /etc/network/interfaces
cp /moot/deploy/src/interfaces /etc/network/
ifup enp0s8

# configure ssh
fm -rf /etc/ssh/sshd_config
cp /moot/deploy/src/sshd_config /etc/ssh/

# configure apache2 with SSL requirements
openssl   req   -x509   -nodes   -days   365   -newkey   rsa:2048   -keyout   /etc/ssl/private/apache-selfsigned.key   -out /etc/ssl/certs/apache-selfsigned.crt  -subj "/C=RU/ST=Moscow/L=Moscow/O=21/OU=school/CN=192.168.56.2"
cp /root/deploy/src/ssl-params.conf /etc/apache2/conf-available/
rm -rf /etc/apache2/sites-available/default-ssl.conf
cp /root/deploy/src/default-ssl.conf /etc/apache2/sites-available/
rm -rf /etc/apache2/sites-available/000-default.conf
cp /root/deploy/src/000-default.conf /etc/apache2/sites-available/
a2enmod ssl
a2enmod headers
a2ensite default-ssl
a2enconf ssl-params

# deploy site
rm -rf /var/www/html/index.html
cp -r /root/deploy/site/* /var/www/html

# configure firewall
ufw enable
ufw allow 443
ufw allow 80/tcp
ufw allow 90/tcp

# configure fail2ban
rm -rf /etc/fail2ban/jail.conf
cp /root/deploy/src/jail.conf /etc/fail2ban/

# configure portsentry
rm -rf /etc/default/portsentry
cp /root/deploy/src/portsentry /etc/default/portsentry
rm -rf /etc/portsentry/portsentry.conf
cp /root/deploy/src/portsentry.conf /etc/portsentry/

# configure crontab
cp /root/deploy/src/update_script.sh /etc/cron.d/
cp /root/deploy/src/crontab_checker.sh /etc/cron.d/
rm -rf /etc/crontab
cp /root/deploy/src/crontab /etc/

# disable unused services
systemctl disable console-setup.service
systemctl disable keyboard-setup.service

# final reboot
reboot
