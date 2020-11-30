#!/bin/sh
cd spatialdata/library
export SBT_OPTS="-Xmx16G"
mkdir -p /data/outputs
sbt "project spatialdata; runMain org.openmole.spatialdata.application.matsim.RunMatsim --synthpop --popMode=uniform --jobMode=random --planMode=default --sample=0.5 --FUAName=\""$FUANAME"\" --FUAFile=/data/inputs/GHSFUAS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0_WGS84.gpkg --LAFile=/data/inputs/LADistricts/LAD_WGS84.shp --MSOAFile=/data/inputs/MSOA/EnglandWalesScotland_MSOAWGS84.shp --SPENSERDir=/data/inputs/SPENSER/ --output=/data/outputs/Plans.xml"
