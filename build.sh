#! /bin/bash

# Define base path for all containers
base="/share/Containers"
media="/share/Multimedia"
dl="/share/Download"

# Create muximux container
docker run -d \
  --name=muximux \
  -p 8081:80 \
  -v $base/muximux/config:/config \
  linuxserver/muximux

# Create plex container
docker run -d \
  --name=plex \
  --net=host \
  -e VERSION=latest \
  -v $base/plex/config:/config \
  -v $media/transcode:/transcode \
  -v $media/music:/data/music \
  -v $media/video/:/data/video \
  linuxserver/plex

docker run -d \
  --name=plexpy \
  -p 8181:8181 \
  -v $base/plexpy/config:/config \
  -v $base/plex/config/Library/Application\ Support/Plex\ Media\ Server/Logs:/logs:ro \
  linuxserver/plexpy

# Create nzbget container
docker run -d \
  --name nzbget \
  -p 6789:6789 \
  -v $base/nzbget/config:/config \
  -v $dl:/downloads/ \
  -v $media:/output \
  linuxserver/nzbget

# Create transmission container
docker run --privileged -d \
  --name=transmission \
  -v $base/transmission/config:/config \
  -v $dl/torrent:/downloads \
  -v $dl/torrent:/watch \
  -p 9091:9091 \
  -p 51413:51413 \
  -p 51413:51413/udp \
  transmission-openvpn

# Create hydra container
docker run -d \
  --name=hydra \
  --link=nzbget \
  -p 5075:5075 \
  -v $base/hydra/config:/config \
  -v $dl:/downloads \
  linuxserver/hydra

# Create jacket tcontainer
docker run -d \
  --name=jackett \
  -v $base/jackett/config:/config \
  -v $dl/torrent:/downloads \
  -p 9117:9117 \
  linuxserver/jackett

# Create couchpotato container
docker run -d \
  --name=couchpotato \
  --link=jackett \
  --link=nzbget \
  --link=transmission \
  -p 5050:5050 \
  -v $base/couchpotato/config:/config \
  -v $dl:/downloads \
  -v $media/video/Movies:/movies \
  linuxserver/couchpotato

# Create sonarr container
docker run -d \
  --name=sonarr \
  --link=jackett \
  --link=nzbget \
  --link=transmission \
  -p 8989:8989 \
  -v $base/sonarr/config:/config \
  -v $media/video/TV\ Shows:/tv \
  -v $dl:/downloads \
  linuxserver/sonarr
