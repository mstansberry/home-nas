#! /bin/bash
# Usage: build.sh all

# Read input
name="$1"
if [[ $name == "" ]]; then
  name="all"
fi

# Define base path for all
base="/share/Containers"
media="/share/Multimedia"
dl="/share/Download"

# Create media-vpn container (openvpn)
# Ports: deluge=8112 jackett=9117
if [[ $name == "media-vpn" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name=media-vpn \
    -h media-vpn \
    --device=/dev/net/tun \
    --cap-add=NET_ADMIN \
    -e PUID=500 -e PGID=100 \
    -e FORCEVPN=true \
    -p 8112:8112 \
    -p 9117:9117 \
    -v $base/media-vpn/config:/config \
    openvpn
fi

# Create plex container
if [[ $name == "plex" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name plex \
    -h plex \
    --net=host \
    -e PUID=500 -e PGID=100 \
    -e VERSION=latest \
    -v $base/plex/config:/config \
    -v $base/plex/transcode:/transcode \
    -v $media:/data \
    linuxserver/plex
fi

# Create nzbget container
if [[ $name == "nzbget" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name nzbget \
    -h nzbget \
    -e PUID=500 -e PGID=100 \
    -p 6789:6789 \
    -v $base/nzbget/config:/config \
    -v $dl:/downloads \
    -v $media:/media \
    linuxserver/nzbget
fi

# Create deluge container
if [[ $name == "deluge" || $name == "all" ]]; then
  docker run -d \
    --name deluge \
    --net=container:media-vpn \
    -e PUID=500 -e PGID=100 \
    -v $dl:/downloads \
    -v $base/deluge/config:/config \
    deluge
fi

# Create hydra container
if [[ $name == "hydra" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name hydra \
    -h hydra \
    -e PUID=500 -e PGID=100 \
    -p 5075:5075 \
    -v $base/hydra/config:/config \
    linuxserver/hydra
fi

# Create jacket tcontainer
if [[ $name == "jackett" || $name == "all" ]]; then
  docker run -d \
    --name jackett \
    --net=container:media-vpn \
    -e PUID=500 -e PGID=100 \
    -v $base/jackett/config:/config \
    -v $dl:/downloads \
    linuxserver/jackett
fi

# Create couchpotato container
if [[ $name == "couchpotato" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name couchpotato \
    -h couchpotato \
    --link=media-vpn:deluge \
    -e PUID=500 -e PGID=100 \
    --link media-vpn:deluge \
    -p 5050:5050 \
    -v $base/couchpotato/config:/config \
    -v $dl:/downloads \
    -v $media:/media \
    linuxserver/couchpotato
fi

# Create sonarr container
if [[ $name == "sonarr" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name sonarr \
    -h sonarr \
    -e PUID=500 -e PGID=100 \
    -p 8989:8989 \
    -v $base/sonarr/config:/config \
    -v $dl:/downloads \
    -v $media/video/TV\ Shows/:/tv \
    linuxserver/sonarr
fi

# Create muximux container
if [[ $name == "muximux" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name muximux \
    -h muximux \
    -e PUID=500 -e PGID=100 \
    -p 8081:80 \
    -v $base/muximux/config:/config \
    linuxserver/muximux
fi
