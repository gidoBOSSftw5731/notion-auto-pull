#!/bin/bash

export token={TOKEN}
export spaceid={SPACEID}

cd
mkdir notion_backups 2>/dev/null
cd notion_backups

#get task
task=`curl --header "Content-Type: application/json" --data '{"task":{"eventName":"exportSpace","request":{"spaceId":"${spaceid}","exportOptions":{"exportType":"markdown","timeZone":"America/New_York","locale":"en"}}}}' --cookie "token_v2=${token}" https://www.notion.so/api/v3/enqueueTask/ --output - --fail --silent --show-error`

#if this fails, your token is probably wrong, but do check the http error, 401 is forbidden which is token issue.
if [ "$?" != 0 ]
then
	exit $?
fi

#command to get task ID
#echo $task  | jq '.taskId'

starttime=`date +%s`


while true
do
	#check for readiness
	out=$(curl --cookie "token_v2=${token}" --header "Content-Type: application/json" --data "{\"taskIds\": [`echo $task  | jq '.taskId'`]}" https://www.notion.so/api/v3/getTasks/ --output - --fail --silent --show-error)

	#echo $out

	if [ "`echo $out | jq '.results[0].state'`" == '"success"' ]
	then
		curl --fail --silent --show-error -o ./`date -Iminutes`.zip --header "Content-Type: application/json"  --cookie "token_v2=${token}" `echo "$out" | jq '.results[0].status.exportURL'|sed 's/^"\(.*\)"$/\1/'` 
		exit $?
	fi

	if (( $starttime+60 < `date +%s` ))
	then
		echo "tried for 60 seconds and it did not provide a download!"
		exit 255
	fi
	sleep 1
done
