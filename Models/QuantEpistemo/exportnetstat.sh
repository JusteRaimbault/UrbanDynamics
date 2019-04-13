DATE=`date +'%Y%m%d_%H%M'`
mongoexport -d urbmod -c netstat --type=csv -f "ipcount,docs" -q '{"ipcount":{$exists:true}}' -o netstat/netstat_$DATE.csv
mongoexport -d urbmod -c netstat --type=csv -f "ip,success,ts" -q '{"ip":{$exists:true}}' -o netstat/netstat_all_$DATE.csv


