#!/bin/sh

# input files from upstream models
cp /inputs/Network_$FUANAME.xml ./Network.xml
cp /inputs/$FUANAME.xml ./Plans.xml

rm -rf output
java -Xmx2G -cp matsim-0.10.1/matsim-0.10.1.jar  org.matsim.run.Controler config.xml
#cp /root/map_network.ipynb /data/outputs/map_network.ipynb
mkdir -p /data/outputs
cp -r output /data/outputs
