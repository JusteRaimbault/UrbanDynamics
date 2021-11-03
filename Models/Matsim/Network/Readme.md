
preprocess network and transit data 
 generateOsmosisScript.sh -> generate extractFUAsOSM.sh and polys files, to be run to extract osm

constructNetworkFUA.sh -> run for one area (on all with awk on ls poly files)
  `ls runtime | grep poly | awk -F"." '{print "./constructNetworkFUA.sh "$1}'`


Map public transit to network:
https://github.com/matsim-org/pt2matsim/wiki/PTMapper-algorithm-and-config-parameters

