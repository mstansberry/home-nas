#! /bin/bash
# Usage: build.sh all

# Read input
name="$1"
if [[ $name == "" ]]; then
  name="all"
fi

# Define base path for all
source .env

# Create media-vpn container (openvpn)
# Ports: hydra=5075 radarr=7878 deluge=8112 sonarr=8989
if [[ $name == "media-vpn" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name=media-vpn \
    -h media-vpn \
    --device=/dev/net/tun \
    --cap-add=NET_ADMIN \
    -e PUID=$PUID -e PGID=$PGID \
    -e FORCEVPN=true \
    -p 5075:5075 \
    -p 7878:7878 \
    -p 8112:8112 \
    -p 8989:8989 \
    -v $base/media-vpn/config:/config \
    openvpn
fi

# Create mariadb container for kodi db
if [[ $name == "mariadb" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name mariadb \
    -h mariadb \
    -e PUID=$PUID -e PGID=$PGID \
    -e MYSQL_ROOT_PASSWORD=####### \
    -p 3306:3306 \
    -v $base/mariadb/config:/config \
    linuxserver/mariadb:latest
fi

# Create nzbget container for usenet download
if [[ $name == "nzbget" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name nzbget \
    -h nzbget \
    -e PUID=$PUID -e PGID=$PGID \
    -p 6789:6789 \
    -v $base/nzbget/config:/config \
    -v $dl:/downloads \
    -v $media:/media \
    linuxserver/nzbget:latest
fi

# Create deluge container for torrent download
if [[ $name == "deluge" || $name == "all" ]]; then
  docker run -d \
    --name deluge \
    --net=container:media-vpn \
    -e PUID=$PUID -e PGID=$PGID \
    -v $dl:/downloads \
    -v $base/deluge/config:/config \
    linuxserver/deluge:latest
fi

# Create hydra container for usenet lookup
if [[ $name == "hydra" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name hydra \
    -e PUID=$PUID -e PGID=$PGID \
    --net=container:media-vpn \
    -v $base/hydra/config:/config \
    linuxserver/hydra:latest
fi

# Create radarr container for movie tracking
if [[ $name == "radarr" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name radarr \
    -e PUID=$PUID -e PGID=$PGID \
    --net=container:media-vpn \
    -v $base/radarr/config:/config \
    -v $dl:/downloads \
    -v $media/video/Movies/:/movies \
    linuxserver/radarr:latest
fi

# Create sonarr container for tv show tracking
if [[ $name == "sonarr" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name sonarr \
    -e PUID=$PUID -e PGID=$PGID \
    --net=container:media-vpn \
    -v $base/sonarr/config:/config \
    -v $dl:/downloads \
    -v $media/video/TV\ Shows/:/tv \
    linuxserver/sonarr:latest
fi

# Create muximux container for unified interface
if [[ $name == "muximux" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name muximux \
    -h muximux \
    -e PUID=$PUID -e PGID=$PGID \
    -p 8081:80 \
    -v $base/muximux/config:/config \
    linuxserver/muximux:latest
fi

# Create ubiquiti container for network mgmt
if [[ $name == "unifi" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name unifi \
    -h unifi \
    -e PUID=$PUID -e PGID=$PGID \
    -p 8090:8080 \
    -p 8091:8081 \
    -p 8443:8443 \
    -p 8843:8843 \
    -p 8880:8880 \
    -v $base/unifi/config:/config \
    linuxserver/unifi:latest
fi

# Create nextcloud container for home cloud
if [[ $name == "nextcloud" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name nextcloud \
    -h nextcloud \
    -p 8082:80 \
    -v $base/nextcloud/apps:/var/www/html/apps \
    -v $base/nextcloud/config:/var/www/html/config \
    -v /share/home_cloud:/var/www/html/data \
    nextcloud:latest
fi