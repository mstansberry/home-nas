#! /bin/bash

# Define base path for all containers
base="/share/Containers"
media="/share/Multimedia"
dl="/share/Download"

# Restore configs from backups
for name in $(ls $base/backup/*.tgz | cut -d/ -f5 | cut -d. -f1); do
  docker rm -f $name
  if [ ! -d $base/$name ]; then
    mkdir $base/$name $base/$name/config
  fi
  tar zxvf $base/backup/$name.tgz $base/$name/
done

docker run -d \
  --restart=always \
  --name=media-vpn \
  -h media-vpn \
  --device=/dev/net/tun \
  --cap-add=NET_ADMIN \
  -p 1080:1080 \
  -p 9080:80 \
  -p 9117:9117 \
  -v $base/media-vpn/config/openvpn.ovpn:/ovpn.conf:ro \
  -v $base/media-vpn/config/openvpn.cred:/openvpn.cred:ro \
  mook/openvpn-client-socks

# Create plex container
docker run -d \
  --name plex \
  -h plex \
  --net=host \
  -e VERSION=latest \
  -v $base/plex/config:/config \
  -v $media/transcode:/transcode \
  -v $media:/data \
  linuxserver/plex

# Create plexpy container
docker run -d \
  --name plexpy \
  -h plexpy \
  -p 8181:8181 \
  -v $base/plexpy/config:/config \
  -v $base/plex/config/Library/Application\ Support/Plex\ Media\ Server/Logs:/logs:ro \
  linuxserver/plexpy

# Create nzbget container
docker run -d \
  --name nzbget \
  -h nzbget \
  -p 6789:6789 \
  -v $base/nzbget/config:/config \
  -v $dl:/downloads \
  -v $media:/media \
  linuxserver/nzbget

# Create rutorrent container
docker run -d \
  --name rutorrent \
  --net=container:media-vpn \
  -v $base/rutorrent/config:/config \
  -v $dl:/downloads \
  -v $media:/media \
  linuxserver/rutorrent

# Create hydra container
docker run -d \
  --name hydra \
  -h hydra \
  -v $base/hydra/config:/config \
  -p 5075:5075 \
  linuxserver/hydra

# Create jacket tcontainer
docker run -d \
  --name jackett \
  --net=container:media-vpn \
  -v $base/jackett/config:/config \
  -v $dl:/downloads \
  linuxserver/jackett

# Create couchpotato container
docker run -d \
  --name couchpotato \
  -h couchpotato \
  -p 5050:5050 \
  -v $base/couchpotato/config:/config \
  -v $dl:/downloads \
  -v $media:/media \
  linuxserver/couchpotato

# Create sonarr container
docker run -d \
  --name sonarr \
  -h sonarr \
  -p 8989:8989 \
  -v $base/sonarr/config:/config \
  -v $dl:/downloads \
  -v $media/video/TV\ Shows/:/tv \
  linuxserver/sonarr

# Create muximux container
docker run -d \
  --name muximux \
  -h muximux \
  -p 8081:80 \
  -v $base/muximux/config:/config \
  linuxserver/muximux
