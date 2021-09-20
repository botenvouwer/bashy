#!/usr/bin/env bash
SCRIPT=`basename ${BASH_SOURCE[0]}`

DB_PORT=${DB_PORT:-5432}
DB_HOST=${DB_HOST:-localhost}
DB_NAME=${DB_NAME:-pdok}
DB_USERNAME=${DB_USERNAME:-postgres}
DB_PASSWORD=${DB_PASSWORD:-postgres}
DB_SCHEMA=${DB_SCHEMA:-"public"}
DB_SOURCE_SCHEMA=${DB_SOURCE_SCHEMA:-"public"}
DB_SSL_MODE=${DB_SSL_MODE:-"prefer"}

#Help function
function HELP {
  echo -e "Wrapper around ogr2ogr."\\n
  echo -e "Basic usage: $SCRIPT -g test.gpkg"\\n
  echo -e "The following switches are recognized."
  echo -e "-t   Target Database schema.  -  Default is env DB_SCHEMA or:    '$DB_SCHEMA'."
  echo -e "-p   Database port.           -  Default is env DB_PORT or:      '$DB_PORT'."
  echo -e "-H   Database host.           -  Default is env DB_HOST or:      '$DB_HOST'."
  echo -e "-d   Database name.           -  Default is env DB_NAME or:      '$DB_NAME'."
  echo -e "-u   Database username.       -  Default is env DB_USERNAME or:  '$DB_USERNAME'."
  echo -e "-P   Database password.       -  Default is env DB_PASSWORD or:  '$DB_PASSWORD'."
  echo -e "-s   Source Database schema.  -  Default is env DB_SCHEMA or:    '$DB_SOURCE_SCHEMA'."
  echo -e "-S   Database ssl mode.       -  Default is env DB_SSL_MODE or:  '$DB_SSL_MODE'."
  echo -e "-h   Show this help text."
  exit 1
}

while getopts "t:p:H:d:u:P:s:S:h" opt; do
  case ${opt} in
   t )
     DB_SCHEMA=$OPTARG
     ;;
   p )
     DB_PORT=$OPTARG
     ;;
   H )
     DB_HOST=$OPTARG
     ;;
   d )
     DB_NAME=$OPTARG
     ;;
   u )
     DB_USERNAME=$OPTARG
     ;;
   P )
     DB_PASSWORD=$OPTARG
     ;;
   s )
     DB_SOURCE_SCHEMA=$OPTARG
     ;;
   S )
     DB_SSL_MODE=$OPTARG
     ;;
   h )
     HELP
     ;;
   \?) #unrecognized option - show help
      echo -e \\n"Option -$OPTARG$ not allowed."
      HELP
      ;;
 esac
done


PG_CONN_SOURCE="PG:host=${DB_HOST} port=${DB_PORT} user=${DB_USERNAME} dbname=${DB_NAME} password=${DB_PASSWORD} sslmode=${DB_SSL_MODE} schemas=${DB_SOURCE_SCHEMA}"
PG_CONN_TARGET="PG:host=${DB_HOST} port=${DB_PORT} user=${DB_USERNAME} dbname=${DB_NAME} password=${DB_PASSWORD} sslmode=${DB_SSL_MODE} schemas=${DB_SCHEMA}"

ogrinfo "${PG_CONN_TARGET}" -sql "CREATE SCHEMA IF NOT EXISTS ${DB_SCHEMA}"
ogr2ogr -f PostgreSQL "${PG_CONN_TARGET}" "${PG_CONN_SOURCE}"