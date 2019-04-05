
ps -ef | grep torpid | awk -F" " '{print "kill -9 "$2}' | sh
ps -ef | grep torpool | awk -F" " '{print "kill -9 "$2}' | sh

