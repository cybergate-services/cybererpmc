#!/usr/bin/env bash

echo "Enter Odoo customer name"
while [ -z "${CUSTOMER_NAME}" ]; do
  read -p "Odoo customer name: " -e CUSTOMER_NAME
  if [ -z ${CUSTOMER_NAME} ]; then
    echo "Customer name cannot be empty. Please re-enter it again"
  fi
done
cp customer.yml.tmpl ${CUSTOMER_NAME}.yml



echo "Enter SMTP host that will be used to send mails from Odoo"
while [ -z "${SMTP_HOST}" ]; do
  read -p "SMTP Host: " -e SMTP_HOST
  DOTS=${SMTP_HOST//[^.]};
  if [ ${#DOTS} -lt 2 ] && [ ! -z ${SMTP_HOST} ]; then
    echo "${SMTP_HOST} is not a FQDN"
    CYBERERP_HOSTNAME=
  fi
done

echo "Enter mail account to be used as Odoo and pgAdmin Administrator account"
while [ -z "${ODOO_EMAIL}" ]; do
  read -p "Admintrator's Email: " -e ODOO_EMAIL
  ATS=${ODOO_EMAIL//[^@]};
  if [ ${#ATS} -ne 1 ] && [ ! -z ${ODOO_EMAIL} ]; then
    echo "${ODOO_EMAIL} is not a valid email"
    ODOO_EMAIL=
  fi
done

echo "Enter SMTP user that will be used to send mails from Odoo"
while [ -z "${SMTP_USER}" ]; do
  read -p "SMTP User: " -e SMTP_USER
  ATS=${SMTP_USER//[^@]};
  if [ ${#ATS} -ne 1 ] && [ ! -z ${SMTP_USER} ]; then
    echo "${SMTP_USER} is not a valid email address"
    SMTP_USER=
  fi
done

echo "Enter SMTP User Password that will be used to send mails from Odoo"
while [ -z "${SMTP_PASSWORD}" ]; do
  read -p "SMTP Password: " -e SMTP_PASSWORD
  count=`echo ${#SMTP_PASSWORD}`
  # echo $count
  if [[ $count -lt 8 ]];then
     echo "Password length should be at least 8 charactors"
     SMTP_PASSWORD=
  fi
  echo ${SMTP_PASSWORD} | grep "[A-Z]" | grep "[a-z]" | grep "[0-9]" | grep "[@#$%^&*]"
  if [[ $? -ne 0 ]];then
    echo "Password must contain upparcase ,lowecase,number and special charactor"
    SMTP_PASSWORD=
  fi
done

PASSWORD=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 | head -c 28)

POSTGRESQL_PASSWORD=${PASSWORD}
ODOO_PASSWORD=${PASSWORD}
ADMIN_PASSWORD=${PASSWORD}
EMAIL=${ODOO_EMAIL}
DHLEVEL=2048 
ONLY_SUBDOMAINS=true 
STAGING=false

cat << EOF > env_${CUSTOMER_NAME}.conf

# ----------------------------------
# POSTGRESQL Database Environment
# ----------------------------------
POSTGRESQL_PASSWORD=${PASSWORD}

# -------------------
# ODOO Environment
# -------------------
ODOO_EMAIL=${ODOO_EMAIL}
ODOO_PASSWORD=${ODOO_PASSWORD}
POSTGRESQL_USER=postgres
POSTGRESQL_PASSWORD=${PASSWORD}
POSTGRESQL_HOST=postgresql
POSTGRESQL_PORT_NUMBER=5432
SMTP_HOST=${SMTP_HOST}
SMTP_PORT=465
SMTP_USER=${SMTP_USER}
SMTP_PASSWORD=${SMTP_PASSWORD}
SMTP_PROTOCOL=ssl
EOF

cat << EOF > ${CUSTOMER_NAME}-net.conf
cybererp-CUSTOMER-net:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: br-CUSTOMER
    enable_ipv6: false
    ipam:
      driver: default
EOF
cat << EOF > ${CUSTOMER_NAME}-letsencrypt.conf 
       cybererp-CUSTOMER-net:
        aliases:
          - letsencrypt

EOF
cat << EOF > ${CUSTOMER_NAME}-pgadmin.conf 
       cybererp-CUSTOMER-net:
        aliases:
          - pgadmin
EOF

cat << EOF > ${CUSTOMER_NAME}-portainer.conf 
       cybererp-CUSTOMER-net:
        aliases:
          - portainer
EOF
cat << EOF > ${CUSTOMER_NAME}-duplicati.conf 
       cybererp-CUSTOMER-net:
        aliases:
          - duplicati
EOF
 
 
 
mkdir -p ./postgresql_${CUSTOMER_NAME}_data
chmod 1777 ./postgresql_${CUSTOMER_NAME}_data
cat ${CUSTOMER_NAME}-net.conf >> network.yml
cat ${CUSTOMER_NAME}-letsencrypt.conf >> letsencrypt.yml
cat ${CUSTOMER_NAME}-pgadmin.conf >> pgadmin.yml
cat ${CUSTOMER_NAME}-duplicati.conf >> duplicati.yml
cat ${CUSTOMER_NAME}-portainer.conf >> portainer.yml

sed -i "s/CUSTOMER/${CUSTOMER_NAME}/g" letsencrypt.yml
sed -i "s/CUSTOMER/${CUSTOMER_NAME}/g" pgadmin.yml
sed -i "s/CUSTOMER/${CUSTOMER_NAME}/g" duplicati.yml
sed -i "s/CUSTOMER/${CUSTOMER_NAME}/g" portainer.yml
sed -i "s/CUSTOMER/${CUSTOMER_NAME}/g" portainer.yml
 

