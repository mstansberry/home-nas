#! /bin/bash
# Usage: restore.sh all

# Read input
name="$1"
if [[ $name == "" ]]; then
  name="all"
fi

gpg_key="$2"

# Define base path for all containers
base="/share/Containers"

# Restore configs from backups
if [[ $name == "all" ]]; then
  for cont in $(ls $base/backup/*.gpg | cut -d/ -f5 | cut -d. -f1); do
    docker rm -f $cont
    if [ ! -d $base/$cont ]; then
      mkdir $base/$cont $base/$cont/config
    fi
    echo "$gpg_key" | gpg --passphrase-fd 0 --batch -d $base/backup/$cont.tgz.gpg | tar zxv -C $base/$cont/
  done
  . $base/build.sh all
else
  docker rm -f $name
  if [ ! -d $base/$name ]; then
    mkdir $base/$name $base/$name/config
  fi

  if [ ! -f $base/backup/$name.tgz ]; then
    echo "$gpg_key" | gpg --passphrase-fd 0 --batch -d $base/backup/$name.tgz.gpg | tar zxv -C $base/$name/
  fi
  . $base/build.sh $name
fi
