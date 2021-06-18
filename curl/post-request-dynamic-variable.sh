#!/bin/bash

function postDelivery {
	echo -n posting delivery to timeline $1...
	local result=`curl -X POST --header "Content-Type: application/json" -d @$2 $DELIVERY_SERVICE_URL/timelines/$1/deliveries 2> /dev/null`

	lastDeliveryId=`echo $result | jq -r ".deliveryID"`
	export "$3"="$lastDeliveryId"

	if [[ `echo $result | jq ".success"` != "true" ]]
	then
		echo " FAILURE"

		>&2 echo error: failed post to delivery-service
		exit 1
	fi
	echo " OK"
}


function waitForProcessed {
	while :
	do
	  echo -n check if delivery $2 on timeline $1 is processed...
		local result=`curl $DELIVERY_SERVICE_URL/timelines/$1/deliveries/$2/events?count=1 2> /dev/null`

		local statusValue=`echo $result | jq -r 'map(select(.type == "STATUS"))[0].value'`
		echo " $statusValue"

		if [[ $statusValue == "PROCESSED" ]]
		then
			break
		fi

		if [[ $statusValue == "FAILED" ]]
		then
			>&2 echo error: delivery processing failed
			exit 1
		fi

		echo "waiting..."
		sleep 60
	done
}

postDelivery $TIMELINE_ID ./requests/tag-delivery-ihr-vvp-1.json "DELIVERY_1_ID"
postDelivery $TIMELINE_ID ./requests/tag-delivery-ihr-vvp-2.json "DELIVERY_2_ID"

waitForProcessed $TIMELINE_ID $DELIVERY_1_ID
waitForProcessed $TIMELINE_ID $DELIVERY_2_ID
