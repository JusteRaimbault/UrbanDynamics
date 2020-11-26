#!/bin/sh
cd spatialdata/library
sbt "project spatialdata; runMain org.openmole.spatialdata.application.matsim.RunMatsim --network --FUAName=\""$FUANAME"\" --FUAFile=/data/inputs/GHSFUAS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0_WGS84.gpkg --TilesFile=/data/inputs/OSOpenRoadsTiles/OSOpenRoadsTiles.shp --datadir=/data/inputs/OSOpenRoads/data --output=/data/outputs/Network;"
#cp -r data /data/outputs
