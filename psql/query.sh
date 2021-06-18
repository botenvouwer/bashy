#!/bin/bash

DB_HOST=localhost
DB_PORT=5432
DB_NAME=deliveries
DB_SSL_MODE=disable
DB_URL=jdbc:postgresql://localhost:5432/deliveries
DB_USERNAME=postgres
DB_PASSWORD=postgres
export PGPASSWORD=postgres
DB_SCHEMA=deliveries_vormvrijeplannen_v1

(
psql -X -A -t \
  -h ${DB_HOST} \
  -p ${DB_PORT} \
  -d ${DB_NAME} \
  -U ${DB_USERNAME} \
  --set=sslmode=${DB_SSL_MODE}\
  --no-align \
  --quiet \
  --tuples-only \
  --field-separator ' ' \
  --pset footer=off \
  <<EOF

    SET search_path TO ${DB_SCHEMA};

    SELECT id, external_id, tag, created_on
    FROM delivery
    WHERE id NOT IN
    (
      SELECT delivery_id as filter_id FROM
      (
        SELECT DISTINCT ON (delivery_id) delivery_id, event_type
        FROM delivery_log
        ORDER BY delivery_id, created_on DESC
      ) sub WHERE sub.event_type IN ('QUEUED','PROCESSING')
      UNION
      (SELECT DISTINCT ON (sub_b.tag) sub_b.delivery_id as filter_id
      FROM (
        SELECT tag, delivery_id, event_type
        FROM delivery_log l
         JOIN delivery d ON d.id = l.delivery_id
        WHERE event_type IN ('PROCESSED')
        ORDER BY tag, delivery_id, l.created_on DESC
      ) sub_b
      ORDER BY sub_b.tag, sub_b.delivery_id DESC)
      UNION
      SELECT delivery_id
      FROM delivery_log
      WHERE event_type = 'CLEANED'
    );
EOF
) | while read ID EXTERNAL_ID TAG CREATED_ON ; do
  echo "Cleaning tag delivery (${TAG}) with id ${ID} ${EXTERNAL_ID} delivered on ${CREATED_ON}"
done
