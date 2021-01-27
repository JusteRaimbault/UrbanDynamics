#!/bin/sh

# arguments:
#  $FUANAME
#  $SEED

if [ -z "$SEED" ]
then
    SEED=$RANDOM
fi


# input files from upstream models
cp /data/inputs/Network_$FUANAME.xml /root/Network.xml
cp /data/inputs/Plans_$FUANAME.xml /root/Plans.xml

rm -rf output
java -Xmx2G -cp /root/matsim-12.0/matsim-12.0.jar org.matsim.run.Controler /root/config.xml
# command line config available in eqasim but not matsim -> edit xml config
# --config:global.randomSeed $SEED --config:controler.lastIteration 5 --config:controler.writeTripsInterval 1 --config:counts.writeCountsInterval 1
#cp /root/map_network.ipynb /data/outputs/map_network.ipynb
mkdir -p /data/outputs
cp -r output /data/outputs

: '
# test docker locally
docker build --no-cache -t matsim:1.0 .
docker run -it --env FUANAME="Taunton" --env SEED=42 \
-v $CS_HOME/UrbanDynamics/Models/Matsim/test:/data/inputs \
matsim:1.0
'
