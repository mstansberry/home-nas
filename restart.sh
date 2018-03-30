#! /bin/bash

for i in media-vpn mariadb nzbget deluge hydra radarr sonarr muximux unifi; do
    docker restart $i
done