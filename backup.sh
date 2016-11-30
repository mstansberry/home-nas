#! /bin/bash

# Define base path for all containers
base="/share/Containers"

# Export config dirs for containers
if [ ! -d $base/backup ]; then
    mkdir $base/backup
fi

cd $base/media-vpn
tar zcvf $base/backup/media-vpn.tgz config/

for name in $(ls -ld $base/* | grep "^d" | grep -v "backup\|station\|media-vpn" | awk '{print $9}' | cut -d/ -f4); do
  docker stop $name
  cd $base/$name
  chown -R 911:911 config/
  tar zcvf $base/backup/$name.tgz config/
  docker start $name
done
