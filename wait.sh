#!/bin/bash

echo "start"

getstate() {
  curl --fail -X GET --header 'Accept: application/json' 'localhost:8080/validator/v2/status'
  return $?
}

max_retry=6
counter=0

until getstate
do
   sleep 10
   [[ counter -eq $max_retry ]] && echo "Could not connect to inspire validation" && exit 1
   #echo "Trying again. Try #$counter"#use to debug
   ((counter++))
done

echo "Inspire service is up"
