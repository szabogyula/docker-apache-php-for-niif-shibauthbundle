#!/bin/bash

echo Set hostname from environment variable

if [[ -z "$PROJECT_HOSTNAME" ]]; then
    export PROJECT_HOSTNAME=project.local
fi

echo -- hostname
echo 127.0.0.1 "$PROJECT_HOSTNAME" >> /etc/hosts

echo -- apache cert
if [[ ! -f /etc/pki/${PROJECT_HOSTNAME}.key ]]; then
  mkdir /etc/pki
  openssl req -new -nodes -x509 -subj "/C=HU/ST=Budapest/L=Budapest/O=IT/CN=$PROJECT_HOSTNAME" -days 3650 -keyout /etc/pki/${PROJECT_HOSTNAME}.key -out /etc/pki/${PROJECT_HOSTNAME}.crt
fi

echo -- apache
sed -i -e "s/project.local/$PROJECT_HOSTNAME/g" /etc/apache2/sites-available/000-default.conf

if [[ -f /etc/pki/DigiCertCA.crt ]]; then
    sed -i -e "s/#SSLCertificateChainFile/SSLCertificateChainFile/g" /etc/apache2/sites-available/000-default.conf
fi

echo Set relative document root
if [[ -n "$DOCUMENT_ROOT" ]]; then
	sed -i -e "s#/var/www/project/web#$DOCUMENT_ROOT#g" /etc/apache2/sites-available/000-default.conf
fi

echo start apache2
apachectl start

echo warm up logfiles
curl -s -k https://"$PROJECT_HOSTNAME"/ > /dev/null
curl -s -k https://"$PROJECT_HOSTNAME"/app_dev.php > /dev/null

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