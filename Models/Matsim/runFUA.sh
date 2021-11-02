
# script must be run as sudo if docker requires it

FUANAME=$1
SEED=$2
SAMPLE=$3
CS_HOME=$4

#SAMPLE=0.1
ITERATIONS=5
THREADS=10
MEMORY=18G

# keep previously cached data
#rm -rf data
# use override to compute anyway
#OVERRIDE=true

# context to name simulation results (ex dafni or ubuntu)
CONTEXT=ubuntu

mkdir -p data
mkdir -p simulations

#####
# Network

#if [ ! -f "data/Network_$FUANAME.xml" ] || [ ! -z OVERRIDE ]; then
if [ ! -f "data/Network_$FUANAME.xml" ]; then
    echo "Running network generation for FUA $FUANAME"
    echo "    Data: GHSFUAs: $CS_HOME/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0"
    echo "    Data: OSOpenRoads: $CS_HOME/Data/OrdnanceSurvey/OSOpenRoads"
    #ls $CS_HOME/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0

    docker run --env FUANAME=$FUANAME --env MEMORY=$MEMORY \
      -v $CS_HOME/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0:/data/inputs/GHSFUAS \
      -v $CS_HOME/UrbanDynamics/Models/Matsim/Network/data:/data/inputs/OSOpenRoadsTiles \
      -v $CS_HOME/Data/OrdnanceSurvey/OSOpenRoads:/data/inputs/OSOpenRoads/data \
      matsim-network:1.0

    NWID=`docker ps -a --last 1 -q`

    echo "Container id: $NWID"

    docker cp $NWID:/data/outputs/Network_$FUANAME.xml data

fi

#####
# Population

#if [ ! -f "data/Plans_$FUANAME.xml" ] || [ ! -z OVERRIDE ]; then
if [ ! -f "data/Plans_$FUANAME.xml" ]; then
    echo "Running plans generation for FUA $FUANAME"

    docker run --env FUANAME=$FUANAME --env SAMPLE=$SAMPLE --env MEMORY=$MEMORY \
        -v $CS_HOME/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0:/data/inputs/GHSFUAS \
        -v $CS_HOME/Data/OrdnanceSurvey/Output_Areas__December_2011__Boundaries_EW_BGC-shp:/data/inputs/OA \
        -v $CS_HOME/Data/OrdnanceSurvey/Local_Authority_Districts__December_2019__Boundaries_UK_BUC-shp:/data/inputs/LADistricts \
        -v $CS_HOME/Data/SPENSER/msm_england:/data/inputs/SPENSER/England \
        -v $CS_HOME/Data/SPENSER/msm_scot:/data/inputs/SPENSER/Scotland \
        -v $CS_HOME/Data/SPENSER/msm_wales:/data/inputs/SPENSER/Wales \
        matsim-population:1.0

    POPID=`docker ps -a --last 1 -q`

    echo "Container id: $POPID"

    docker cp $POPID:/data/outputs/Plans_$FUANAME.xml data
fi


#####
# Matsim

echo "Running Matsim for FUA $FUANAME with seed $SEED; iterations $ITERATIONS; threads $THREADS; memory $MEMORY"

ls $CS_HOME/UrbanDynamics/Models/Matsim/data

docker run --env FUANAME="$FUANAME" --env SEED=$SEED --env ITERATIONS=$ITERATIONS --env THREADS=$THREADS --env MEMORY=$MEMORY \
  -v $CS_HOME/UrbanDynamics/Models/Matsim/data:/data/inputs \
  matsim:1.0

MATSIMID=`docker ps -a --last 1 -q`

echo "Container id: $MATSIMID"

docker cp $MATSIMID:/data/outputs "simulations/matsim-output_FUA-"$FUANAME"_seed-"$SEED"_sample-"$SAMPLE"_"$CONTEXT

