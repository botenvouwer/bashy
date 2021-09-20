#!/bin/bash
set -eu
set -o pipefail
#title          :overpompscript.sh
#description    :Dit script zal van de 'ene' database de schema's na wens dumpen en restoren op de 'andere' database
#author         :Gerben Danen
#date           :20210112
#version        :0.5
#usage          :bash overpompscript.sh schemanaam
#note           :Installeer postgresql-client alvorens dit script te draaien
#bash_version   :4.1.5(1)-release
#=========================================================49187==============================================================
restore_server='csu1242.cs.kadaster.nl'
restore_port=49187
restore_user='pdok_owner'
restore_passw='uZ5HPDol7oTDjxyi5lXGAo9ZIZTpt0bJ'
restore_dbname='pdok'

dump_server='inu884.in.kadaster.nl'
dump_port=49187
dump_user='postgres'
dump_passw='7b39c56d49efe71453d4090a38f504bd'
dump_dbname='pdok'

schema_name=$1

if [[ "$schema_name" != "" ]]; then
  start_tijd=$SECONDS
  echo "Start met het overzetten van $schema_name schema. Dump maken wordt gestart."
  export PGPASSWORD=$dump_passw
  pg_dump -Fc -h $dump_server -p $dump_port -U $dump_user -d $dump_dbname -n "$schema_name" >pdok_"$schema_name".dump
  echo "Dumpen van $schema_name schema compleet. Nu wordt de restore gestart."
  export PGPASSWORD=$restore_passw
  pg_restore -Fc -h $restore_server -p $restore_port -U $restore_user -d $restore_dbname pdok_"$schema_name".dump
  echo "Klaar met het restoren van het $schema_name schema. Dump bestand wordt opgeruimd."
  #rm pdok_"$schema_name".dump
  eind_tijd=$(($SECONDS - $start_tijd))
  echo "Afgerond in $eind_tijd seconden."
  exit 0
else
  echo "Vul als eerste parameter een schema naam in."
  exit 1
fi
