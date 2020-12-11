#!/bin/sh

# REGION env variable must be set

# workflow for a full household - individuals microsimulation is
#  - run household microsimulation in dir household_microsynth
#  - run household microsimulation in dir microsimulation (difference?)
#  - run population microsimulation in dir microsimulation
#  - run assignement in dir microsimulation

mkdir -p /data/outputs

cd /home/docker/household_microsynth
./run.sh
cp -r data /data/outputs/household

cd /home/docker/microsimulation
./hrun.sh
./run.sh
./arun.sh
cp -r data /data/outputs/population
