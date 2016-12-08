#! /bin/bash
# Usage: backup.sh all
# echo "0 15 * * * * /share/Containers/vpn_checkup.sh all" >> /etc/config/crontab && crontab /etc/config/crontab

host_ip=$(wget http://ipinfo.io/ip -qO -)
cont_ip=$(docker exec media-vpn wget http://ipinfo.io/ip -qO -)
if [[ $host_ip == $cont_ip ]]; then
  docker restart media-vpn deluge jackett
fi
