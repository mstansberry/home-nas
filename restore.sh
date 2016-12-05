#! /bin/bash
# Usage: restore.sh all

# Read input
name="$1"
if [[ $name == "" ]]; then
  name="all"
fi

# Define base path for all containers
base="/share/Containers"
media="/share/Multimedia"
dl="/share/Download"

# Restore configs from backups
if [[ $name == "all" ]]; then
  for cont in $(ls $base/backup/*.tgz | cut -d/ -f5 | cut -d. -f1); do
    docker rm -f $cont
    if [ ! -d $base/$cont ]; then
      mkdir $base/$cont $base/$cont/config
    fi
    tar zxvf $base/backup/$cont.tgz -C $base/$cont/
  done
  . $base/build.sh all
else
  docker rm -f $name
  if [ ! -d $base/$name ]; then
    mkdir $base/$name $base/$name/config
  fi

  if [ ! -f $base/backup/$name.tgz ]; then
    tar zxvf $base/backup/$name.tgz -C $base/$name/
  fi
  . $base/build.sh $name
fi
