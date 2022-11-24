#!/bin/bash

set -euo pipefail

function usage {
	echo "script usage: $(basename \$0) [-l] [-h] [-a somevalue]" >&2
	exit 1
}

while getopts 'lha:' OPTION; do
  case "$OPTION" in
    l)
      echo "linuxconfig"
      ;;
    h)
      echo "you have supplied the -h option"
      ;;
    a)
      avalue="$OPTARG"
      echo "The value provided is $OPTARG"
      ;;
    ?)
	    usage
      ;;
  esac
done
shift "$(($OPTIND -1))"

echo "$# arguments"

if [ -z "${1+x}" ]; then
    usage
fi

echo $1

if [ -z "${2+x}" ]; then
    usage
fi

echo $2

