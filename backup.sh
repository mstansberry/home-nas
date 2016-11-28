#! /bin/bash

# Define base path for all containers
base="/share/Containers"

# Export config dirs for containers
if [ ! -d $base/backup ]; then
    mkdir $base/backup/
fi

for name in $(ls -ld $base/* | grep "^d" | grep -v "backup\|station" | awk '{print $9}' | cut -d/ -f4); do
  docker stop $name
  chown -R 911:911 $base/$name/config
  tar zcvf $base/backup/$name.tgz $base/$name/config
  docker start $name
done
