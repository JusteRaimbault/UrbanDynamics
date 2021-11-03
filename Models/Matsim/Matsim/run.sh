#!/bin/sh

# arguments:
#  $FUANAME
#  $SEED

# does not work in config: need to export
if [ -z "$SEED" ]
then
    export SEED=$RANDOM
fi

if [ -z "$ITERATIONS" ]
then
    export ITERATIONS=5
fi

if [ -z "$THREADS" ]
then
    export THREADS=16
fi

if [ -z "$MEMORY" ]
then
    export MEMORY=18G
fi


# input files from upstream models
cp /data/Network_$FUANAME.xml.gz /root/Network.xml.gz
cp /data/Plans_$FUANAME.xml /root/Plans.xml
cp /data/$FUANAME_transit_schedule.xml.gz /root/transit_schedule.xml.gz

/root/config.sh

rm -rf output
java -Xmx$MEMORY -cp /root/matsim-12.0/matsim-12.0.jar org.matsim.run.Controler /root/config_runtime.xml
# command line config available in eqasim but not matsim -> edit xml config
# --config:global.randomSeed $SEED --config:controler.lastIteration 5 --config:controler.writeTripsInterval 1 --config:counts.writeCountsInterval 1
#cp /root/map_network.ipynb /data/outputs/map_network.ipynb
#mkdir -p /data/outputs
cp -r output /data/

: '
# test docker locally
docker build --no-cache -t matsim:1.0 .
docker run -it --env FUANAME="Taunton" --env SEED=123 --env ITERATIONS=5 --env THREADS=16 --env MEMORY=4G \
-v $CS_HOME/UrbanDynamics/Models/Matsim/test:/data/inputs \
matsim:1.0
'

: '
# build and export docker
docker build --no-cache -t matsim:1.0 .
cd ..
docker save matsim:1.0 | gzip > images/matsim-1.0-`git rev-parse --short=10 HEAD`.tar.gz
'
