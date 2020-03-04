#!/usr/bin/env bash

echo "Enter Odoo customer name"
while [ -z "${CUSTOMER_NAME}" ]; do
  read -p "Odoo customer name: " -e CUSTOMER_NAME
  cd /cybergate/freeapps/CybrosysAddons/CybroAddons/
  cp -r * /opt/cybererpmc/custom-addons/${CUSTOMER_NAME}/
  cd /cybergate/freeapps/CybrosysHRMs/OpenHRMS/
  cp -r * /opt/cybererpmc/custom-addons/${CUSTOMER_NAME}/
  cd /cybergate/freeapps/OtherApps/
  cp -r * /opt/cybererpmc/custom-addons/${CUSTOMER_NAME}/
  cd /opt/cybererpmc/
  docker-compose restart odoo_${CUSTOMER_NAME}
  
  if [ -z ${CUSTOMER_NAME} ]; then
    echo "Customer name cannot be empty. Please re-enter it again"
  fi
done
