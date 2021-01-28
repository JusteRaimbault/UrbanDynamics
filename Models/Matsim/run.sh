
# must be run as sudo if docker requires it
# + need base dir as arg

PARAMFILE=$1
CS_HOME=$2

while read LINE; do
  echo "Run:$LINE"
  NAME="$(echo $LINE | cut -d';' -f1)"
  SEED="$(echo $LINE | cut -d';' -f2)"
  ./runFUA.sh $NAME $SEED $CS_HOME
done <$PARAMFILE


