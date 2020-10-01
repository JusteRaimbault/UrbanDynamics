#!/bin/sh
cd spatialdata/library
sbt "project spatialdata" "run-main org.openmole.spatialdata.test.Test"
#cp -r data /data/outputs
