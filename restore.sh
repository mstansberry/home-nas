#! /bin/bash
# Usage: restore.sh passphrase all

# Read input
gpg_key="$1"
name="$2"
if [[ $name == "" ]]; then
  name="all"
fi

# Define base path for all containers
source .env

# Restore configs from backups
if [[ $name == "all" ]]; then
  for cont in $(ls $base/backup/*.gpg | rev | cut -d/ -f1 | rev | cut -d. -f1); do
    docker rm -f $cont
    if [ ! -d $base/$cont ]; then
      mkdir $base/$cont $base/$cont/config
    fi
    echo "$gpg_key" | gpg --passphrase-fd 0 --batch -d $base/backup/$cont.tgz.gpg | tar zxv -C $base/$cont/
  done
  docker-compose up
else
  docker rm -f $name
  if [ ! -d $base/$name ]; then
    mkdir $base/$name $base/$name/config
  fi
  if [ -f $base/backup/$name.tgz ]; then
    echo "$gpg_key" | gpg --passphrase-fd 0 --batch -d $base/backup/$name.tgz.gpg | tar zxv -C $base/$name/
  fi
  docker-compose up $name
fi
