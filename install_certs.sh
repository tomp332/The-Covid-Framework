#!/bin/bash


######## CHECK FOR SUDO
if ! [ $(id -u) = 0 ]; then	
	echo "[-] Please run this script as root!"
	exit 1
fi


####### CREATE DOCKER VOLUME
if docker volume inspect  --format '{{ .Mountpoint }}' covid-volume  | grep -q '_data'; then
	echo "[+] covid-volume exists moving on"
else
	echo "[-] covid-volume doesn't exist, createing one"
	docker volume create covid-volume
fi


###### CHECK FOR CERTS
domain="covidframework.com"
echo "[+] Checking if a certificate exists and is valid"
if certbot certificates | grep -q "No certificates found."; then
	echo "[-] No certificates found for your domain, trying to create with certbot"
	docker run -p 80:80 --log-driver=none -it certbot/certbot certonly --standalone -d $domain -d www.$domain --register-unsafely-without-email --agree-tos --non-interactive
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
if [[ "$certs_directory" == *"$domain"* ]]; then
	echo "[+] Certificate created successfully"
	echo "[+] Copying new certificates to covid-volume"
	sudo cp $certs_directory/privkey.pem $certs_directory/cert.pem /var/lib/docker/volumes/covid-volume/_data
else
	echo "[-] Certificate failed"
fi
