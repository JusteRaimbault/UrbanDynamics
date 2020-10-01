#!/bin/sh
cd spatialdata/library
sbt "project spatialdata; runMain org.openmole.spatialdata.application.matsim.RunMatsim /root/test/road_line.shp;"
#cp -r data /data/outputs
