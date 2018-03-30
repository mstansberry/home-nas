#! /bin/sh
# Usage: build.sh all

# Read input
name="$1"
if [[ $name == "" ]]; then
  name="all"
fi

if [[ $name == "all" ]]; then
  docker-compose up -d
else
  docker-compose up -d $name
fi
