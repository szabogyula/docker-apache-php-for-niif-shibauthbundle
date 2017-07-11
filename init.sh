#!/bin/bash

echo Set hostname from environment variable

if [[ -n "$PROJECT_HOSTNAME" ]]; then
	echo -- hostname
	echo 127.0.0.1 "$PROJECT_HOSTNAME" >> /etc/hosts

	echo -- apache cert
	openssl req -new -nodes -x509 -subj "/C=HU/ST=Budapest/L=Budapest/O=IT/CN=$PROJECT_HOSTNAME" -days 3650 -keyout /etc/ssl/private/project.local.key -out /etc/ssl/certs/project.local.crt

	echo -- apache
	sed -i -e "s/project.local/$PROJECT_HOSTNAME/g" /etc/apache2/sites-available/000-default.conf
 fi


echo Set relative document root
if [[ -n "$DOCUMENT_ROOT" ]]; then
	sed -i -e "s#/var/www/project/web#$DOCUMENT_ROOT#g" /etc/apache2/sites-available/000-default.conf
fi

echo start apache2
apachectl start

echo warm up logfiles
if [[ -n "$PROJECT_HOSTNAME" ]]; then
	curl -s -k https://"$PROJECT_HOSTNAME"/ > /dev/null
	curl -s -k https://"$PROJECT_HOSTNAME"/app_dev.php > /dev/null
else
	curl -s -k https://project.local/ > /dev/null
	curl -s -k https://project.local/app_dev.php > /dev/null
fi

echo append logfiles to tailon
for i in $(echo $LOGFILES | sed "s/,/ /g")
do
    if ! grep -q $i /etc/tailon.yml
    then
        echo "        - $i" >> /etc/tailon.yml
    fi
done

# filebeat start if there is /tmp/filebeat.yml
if [ -e "/tmp/filebeat.yml" ]; then
    filebeat -e -d '*'
else
    echo start tailon
    cat /etc/tailon.yml
    tailon -c /etc/tailon.yml
fi