#!/usr/bin/env bash

echo "Enter Odoo customer name"
while [ -z "${CUSTOMER_NAME}" ]; do
  read -p "Odoo customer name: " -e CUSTOMER_NAME
  cd /opt/cybererpmc/letsencrypt/config/nginx/proxy-confs
  cp demoerp.subdomain.conf ${CUSTOMER_NAME}.subdomain.conf
  sed -i 's/demoerp/'${CUSTOMER_NAME}'/g' /opt/cybererpmc/letsencrypt/config/nginx/proxy-confs/${CUSTOMER_NAME}.subdomain.conf
  if [ -z ${CUSTOMER_NAME} ]; then
    echo "Customer name cannot be empty. Please re-enter it again"
  fi
done
cd /opt/cybererpmc/
docker-compose restart letsencrypt
