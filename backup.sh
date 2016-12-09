#! /bin/bash
# Usage: backup.sh all
# echo "0 30 3 * * * /share/Containers/backup.sh all" >> /etc/config/crontab && crontab /etc/config/crontab

# Read input
name="$1"
if [[ $name == "" ]]; then
  name="all"
fi

gpg_key="$2"

# Define base path for all containers
base="/share/Containers"

# Export config dirs for containers
if [ ! -d $base/backup ]; then
    mkdir $base/backup
fi

cd $base/media-vpn
rm -f $base/backup/media-vpn.tgz.gpg
tar zcvpf - config/ | gpg --passphrase "$gpg_key" --symmetric --cipher-algo aes256 -o $base/backup/media-vpn.tgz.gpg

if [[ $name == "all" ]]; then
  for cont in $(ls -ld $base/* | grep "^d" | grep -v "backup\|station\|media-vpn\|Recycle" | awk '{print $9}' | cut -d/ -f4); do
    docker stop $cont
    cd $base/$cont
    chown -R media:everyone config/
    rm -f $base/backup/$cont.tgz.gpg
    tar zcvpf - config/ | gpg --passphrase "$gpg_key" --symmetric --cipher-algo aes256 -o $base/backup/$cont.tgz.gpg
    docker start $cont
  done
else
  docker stop $name
  cd $base/$name
  chown -R media:everyone config/
  rm -f $base/backup/$name.tgz.gpg
  tar zcvpf - config/ | gpg --passphrase "$gpg_key" --symmetric --cipher-algo aes256 -o $base/backup/$name.tgz.gpg
  docker start $name
fi
