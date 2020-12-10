#!/bin/sh
cd spatialdata/library
export SBT_OPTS="-Xmx16G"
mkdir -p /data/outputs
sbt "project spatialdata; runMain org.openmole.spatialdata.application.matsim.RunMatsim --synthpop --popMode=uniform --jobMode=random --planMode=default --sample="$SAMPLE" --FUAName=\""$FUANAME"\" --FUAFile=/data/inputs/GHSFUAS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0_WGS84.gpkg --LAFile=/data/inputs/LADistricts/LAD_WGS84.shp --OAFile=/data/inputs/OA/OA2011_WGS84.shp --SPENSERDirs=/data/inputs/SPENSER/England,/data/inputs/SPENSER/Scotland,/data/inputs/SPENSER/Wales --output=/data/outputs/Plans.xml"

: '
# test docker locally
docker build --no-cache -t matsim-population:1.0 .
docker run -it --env FUANAME=Hereford --env SAMPLE=0.1 \
-v $CS_HOME/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0:/data/inputs/GHSFUAS \
-v $CS_HOME/Data/OrdnanceSurvey/Output_Areas__December_2011__Boundaries_EW_BGC-shp:/data/inputs/OA \
-v $CS_HOME/UrbanDynamics/Data/OrdnanceSurvey/LADistricts/Local_Authority_Districts__December_2019__Boundaries_UK_BUC-shp:/data/inputs/LADistricts \
-v $CS_HOME/UrbanDynamics/Data/SPENSER/2020/England:/data/inputs/SPENSER/England \
-v $CS_HOME/UrbanDynamics/Data/SPENSER/2020/Scotland:/data/inputs/SPENSER/Scotland \
-v $CS_HOME/UrbanDynamics/Data/SPENSER/2020/Wales:/data/inputs/SPENSER/Wales \
matsim-population:1.0
'
