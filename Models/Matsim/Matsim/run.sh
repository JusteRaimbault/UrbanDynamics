#!/bin/sh
rm -rf output
java -Xmx2G -cp matsim-0.10.1/matsim-0.10.1.jar  org.matsim.run.Controler config.xml
#cp /root/map_network.ipynb /data/outputs/map_network.ipynb
