#! /bin/bash
# Usage: backup.sh all

# Read input
name="$1"
if [[ $name == "" ]]; then
  name="all"
fi

# Define base path for all containers
base="/share/Containers"

# Export config dirs for containers
if [ ! -d $base/backup ]; then
    mkdir $base/backup
fi

cd $base/media-vpn
tar zcvf $base/backup/media-vpn.tgz config/

if [[ $name == "all" ]]; then
  for cont in $(ls -ld $base/* | grep "^d" | grep -v "backup\|station\|media-vpn" | awk '{print $9}' | cut -d/ -f4); do
    docker stop $cont
    cd $base/$cont
    chown -R 911:911 config/
    tar zcvf $base/backup/$cont.tgz config/
    docker start $cont
  done
else
  docker stop $name
  cd $base/$name
  chown -R 911:911 config/
  tar zcvf $base/backup/$name.tgz config/
  docker start $name
fi
