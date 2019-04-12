mongoexport -d urbmod -c netstat --type=csv -f "ipcount,docs" -q '{"ipcount":{$exists:true}}' -o netstat/netstat_`date +'%Y%m%d_%H%M'`.csv


