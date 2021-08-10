#!/bin/bash

######## CHECK FOR SUDO
if ! [ $(id -u) = 0 ]; then
        echo "[-] Please run this script as root!"
        exit 1
fi


domain="covidframework.com"
volume_dir=$(docker volume inspect  --format '{{ .Mountpoint }}' covid-volume  | grep -q '_data')

####### CREATE DOCKER VOLUME
if [ -z "$volume_dir" ]
then
        echo "[-] covid-volume doesn't exist, createing one"
        docker volume create covid-volume
else
        echo "[+] covid-volume exists, cleaning all data "
        rm -r $volume_dir/$domain*
fi


###### CHECK FOR CERTS
echo "[+] Checking if a certificate exists and is valid"
if certbot certificates | grep -q "No certificates found."; then
        echo "[-] No certificates found for your domain, trying to create with certbot"
        feedback=$(echo $(docker run --mount src=covid-volume,dst=/etc/letsencrypt/archive --name cert -p 80:80 --log-driver=none -it certbot/certbot certonly --standalone -d covidframework.com -d www.covidframework.com --register-unsafely-without-email --agree-tos --non-interactive | grep Error))
        if [ -z "$feedback" ]; then
                echo "[+] Certificate created successfully"
                echo "[+] Copying certs from volume to local certs directory"
                mkdir -p certs
                cp -r /var/lib/docker/volumes/covid-volume/_data/$domain*  certs/
                echo "[+] Changing permissions for domain certificate directory"
                chmod 777 ./certs/$domain*
                rm README
        else
                echo "[-] Failed to create certificates with error:"
                echo $feedback
        fi
else
        echo "[+] Found existing certificates, validating.."
        docker run -t cetbot certonly -n -d $domain -d www.$domain
fi


###### GENERATE NEW CERTS
get_latest_certs_dir ()
{
        certs_dir=sudo find /etc/letsencrypt/archive/ -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "
        return $certs_dir
}
certs_directory=$(get_latest_certs_dir)
