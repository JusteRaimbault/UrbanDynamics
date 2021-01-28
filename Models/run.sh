
# must be run as sudo if docker requires it

PARAMFILE=$1

while read LINE; do
  echo "Run:$LINE"
  NAME="$(echo $LINE | cut -d';' -f1)"
  SEED="$(echo $LINE | cut -d';' -f2)"
  ./runFUA.sh $NAME $SEED
done <$PARAMFILE


