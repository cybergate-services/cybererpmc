#!/usr/bin/env bash

if [ -f cybererp.conf ]; then
  read -r -p "A config file exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv cybererp.conf cybererp.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

if [ -f ./.env ]; then
  rm -f  ./.env
fi

echo "Press enter to confirm the detected value '[value]' where applicable or enter a custom value."
while [ -z "${CYBERERP_HOSTNAME}" ]; do
  read -p "Hostname (FQDN): " -e CYBERERP_HOSTNAME
  DOTS=${CYBERERP_HOSTNAME//[^.]};
  if [ ${#DOTS} -lt 2 ] && [ ! -z ${CYBERERP_HOSTNAME} ]; then
    echo "${CYBERERP_HOSTNAME} is not a FQDN"
    CYBERERP_HOSTNAME=
  fi
done

if [ -a /etc/timezone ]; then
  DETECTED_TZ=$(cat /etc/timezone)
elif [ -a /etc/localtime ]; then
  DETECTED_TZ=$(readlink /etc/localtime|sed -n 's|^.*zoneinfo/||p')
fi

while [ -z "${CYBERERP_TZ}" ]; do
  if [ -z "${CYBERERP_TZ}" ]; then
    read -p "Timezone: " -e CYBERERP_TZ
  else
    read -p "Timezone [${DETECTED_TZ}]: " -e CYBERERP_TZ
    [ -z "${CYBERERP_TZ}" ] && CYBERERP_TZ=${DETECTED_TZ}
  fi
done
PUID=1002
PGID=1002
URL=$(echo ${CYBERERP_HOSTNAME} | cut -n -f 1  -d . --complement)
SUBDOMAINS=odoo,odoo-pgadmin,odoo-portainer,odoo-backup
EXTRA_DOMAINS=
VALIDATION=http
EMAIL=cgadmin@cybergate.lk
DHLEVEL=2048 
ONLY_SUBDOMAINS=true 
STAGING=false

cat << EOF > cybererp.conf
# -------------------------------------
# CyberERP docker-compose Environment
# -------------------------------------
CYBERERP_HOSTNAME=${CYBERERP_HOSTNAME}

#-------------------------
# LETSENCRYPT Environment
#-------------------------
PUID=${PUID}
PGID=${PGID}
URL=${URL}
SUBDOMAINS=${SUBDOMAINS}
EXTRA_DOMAINS=${EXTRA_DOMAINS}
VALIDATION=${VALIDATION}
EMAIL=${EMAIL}
DHLEVEL=${DHLEVEL}
ONLY_SUBDOMAINS=${ONLY_SUBDOMAINS}
STAGING=${STAGING}
TZ=${CYBERERP_TZ}
EOF

ln ./cybererp.conf ./.env

cp letsencrypt.yml.tmpl letsencrypt.yml
cp duplicati.yml.tmpl duplicati.yml
cp network.yml.tmpl network.yml
cp pgadmin.yml.tmpl pgadmin.yml
cp portainer.yml.tmpl portainer.yml
