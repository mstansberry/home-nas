#! /bin/bash
# Usage: backup.sh passphrase all
# echo "0 30 3 * * * /share/Containers/backup.sh passphrase all" >> /etc/config/crontab && crontab /etc/config/crontab

# Read input
gpg_key="$1"
name="$2"
if [[ $name == "" ]]; then
  name="all"
fi

# Define base path for all containers
set -o allexport
source /share/Container/.env
set +o allexport

# Export config dirs for containers
if [ ! -d $base/backup ]; then
    mkdir $base/backup $base/backup/output
fi

cd $base/media-vpn
tar uvpf $base/backup/media-vpn.tar config/ &> $base/backup/media-vpn.log
if [[ ! $(cat $base/backup/media-vpn.log) == "" ]]; then
  cat $base/backup/media-vpn.tar | gpg --passphrase "$gpg_key" --symmetric --cipher-algo aes256 --compression-algo BZIP2 --batch --yes -o $base/backup/output/media-vpn.tgz.gpg
fi
rm -f $base/backup/media-vpn.log

if [[ $name == "all" ]]; then
  for cont in $(ls -ld $base/* | grep "^d" | grep -v "backup\|station\|media-vpn\|Recycle" | awk '{print $8}' | cut -d/ -f4); do
    docker-compose pull $cont
    docker-compose stop $cont
    cd $base/$cont
    chown -R media:everyone config/
    tar uvpf $base/backup/$cont.tar config/ &> $base/backup/$cont.log
    docker-compose up -d $cont
    if [[ ! $(cat $base/backup/$cont.log) == "" ]]; then
      cat $base/backup/$cont.tar | gpg --passphrase "$gpg_key" --symmetric --cipher-algo aes256 --compression-algo BZIP2 --batch --yes -o $base/backup/output/$cont.tgz.gpg
    fi
    rm -f $base/backup/$cont.log
  done
else
  docker-compose pull $name
  docker-compose stop $name
  cd $base/$name
  chown -R media:everyone config/
  tar uvpf $base/backup/$name.tar config/ &> $base/backup/$name.log
  docker-compose up -d $name
  if [[ ! $(cat $base/backup/$name.log) == "" ]]; then
    cat $base/backup/$name.tar | gpg --passphrase "$gpg_key" --symmetric --cipher-algo aes256 --compression-algo BZIP2 --batch --yes -o $base/backup/output/$name.tgz.gpg
  fi
  rm -f $base/backup/$name.log
fi

docker image prune -f