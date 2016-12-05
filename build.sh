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
# built from http://github.com/linuxserver/docker-vpn
# Ports: deluge=8112 jackett=9117
if [[ $name == "media-vpn" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name=media-vpn \
    -h media-vpn \
    --device=/dev/net/tun \
    --cap-add=NET_ADMIN \
    -p 8112:8112 \
    -p 9117:9117 \
    -e FORCEVPN=true \
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
    -e VERSION=latest \
    -v $base/plex/config:/config \
    -v $media/transcode:/transcode \
    -v $media:/data \
    linuxserver/plex
fi

# Create plexpy container
if [[ $name == "plexpy" || $name == "all" ]]; then
  docker run -d \
  --name plexpy \
    -h plexpy \
    -p 8181:8181 \
    -v $base/plexpy/config:/config \
    -v $base/plex/config/Library/Application\ Support/Plex\ Media\ Server/Logs:/logs:ro \
    linuxserver/plexpy
fi

# Create nzbget container
if [[ $name == "nzbget" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name nzbget \
    -h nzbget \
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
    -v $dl:/downloads \
    -v $base/deluge/config:/config \
    linuxserver/deluge
fi

# Create hydra container
if [[ $name == "hydra" || $name == "all" ]]; then
  docker run -d \
    --restart=always \
    --name hydra \
    -h hydra \
    -v $base/hydra/config:/config \
    -p 5075:5075 \
    linuxserver/hydra
fi


# Create jacket tcontainer
if [[ $name == "jackett" || $name == "all" ]]; then
  docker run -d \
    --name jackett \
    --net=container:media-vpn \
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
    -p 8081:80 \
    -v $base/muximux/config:/config \
    linuxserver/muximux
fi
