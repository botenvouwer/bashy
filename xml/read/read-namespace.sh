#!/bin/bash

# read one value
type=$(xmlstarlet sel -T -N xlink="http://www.w3.org/1999/xlink" -N wms="http://www.opengis.net/wms" -t -v '//wms:Service/wms:Name' $CAPABILITIES_XML)
service_title=$(xmlstarlet sel -T -N xlink="http://www.w3.org/1999/xlink" -N wms="http://www.opengis.net/wms" -t -v '//wms:Service/wms:Title' $CAPABILITIES_XML)

# read multiple entities and transform to json
layers_json=$(cat $CAPABILITIES_XML |
          xmlstarlet sel -T -N xlink="http://www.w3.org/1999/xlink" -N wms="http://www.opengis.net/wms" -t -m '//wms:Layer/wms:Layer' -v \
              'concat(wms:Name/text(), ",", wms:Title/text(), ",", wms:Style[1]/wms:LegendURL/wms:OnlineResource/@xlink:href)' -n |
          jq --slurp --raw-input \
              'split("\n") | .[:-1] | map(split(",")) |
                  map({
                      "technicalName": .[0],
                      "name": .[1],
                      "legendUrl": .[2],
                  })')

# 
view_conf_json=$(cat $CAPABILITIES_XML |
    jq  --slurp --raw-input\
        --arg v "$base_url" \
        --arg t "$service_title" \
        --argjson layers "$layers_json" \
              '{
                  "datasetName": $t,
                  "services":[
                    {
                      "type": "wms",
                      "title": $t,
                      "url": $v,
                      "layers": $layers
                    }
                  ]
              }'
)


