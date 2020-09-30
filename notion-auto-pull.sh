#!/bin/bash
#probably could be sh, dont @ me

cd
mkdir notion_backups 2>/dev/null
cd notion_backups

#get task
task=`curl --header "Content-Type: application/json" --data '{"task":{"eventName":"exportSpace","request":{"spaceId":"[SPACE-ID]","exportOptions":{"exportType":"markdown","timeZone":"America/New_York","locale":"en"}}}}' --cookie "token_v2=[COOKIE]" https://www.notion.so/api/v3/enqueueTask/ --output - --fail --silent --show-error`

#command to get task ID
#echo $task  | jq '.taskId'

while true
do
	#check for readiness
	out=$(curl --cookie "token_v2=[COOKIE]" --header "Content-Type: application/json" --data "{\"taskIds\": [`echo $task  | jq '.taskId'`]}" https://www.notion.so/api/v3/getTasks/ --output - --fail --silent --show-error)
	#echo $out
	if [ `echo $out | jq '.results[0].state'` == '"success"' ]
	then
		curl --fail --silent --show-error -o ./`date -Iminutes`.zip --header "Content-Type: application/json"  --cookie "token_v2=[COOKIE]" `echo "$out" | jq '.results[0].status.exportURL'|sed 's/^"\(.*\)"$/\1/'` 
		exit 0
		break
	fi
	sleep 1
done
