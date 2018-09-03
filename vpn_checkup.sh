#! /bin/bash
# Usage: backup.sh all
# echo "0 15 * * * * /share/Containers/vpn_checkup.sh all" >> /etc/config/crontab && crontab /etc/config/crontab

host_ip=$(wget http://ipinfo.io/ip -qO -)
cont_ip=$(docker exec media-vpn wget http://ipinfo.io/ip -qO -)
echo -en "host: $host_ip\ncontainer: $cont_ip\n"
if [[ $host_ip == $cont_ip ]]; then
  docker-compose restart media-vpn
fi
