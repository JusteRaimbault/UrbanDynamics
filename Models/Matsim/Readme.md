
# Open transport modeling using workflow systems

Docker images and DAFNI model definition files for MATSim integration as open source components

 - `Network`: Road network and public transport data preparation for MATSim, using [spatialdata](https://github.com/openmole/spatialdata) library for the road network; [UK2GTFS](https://github.com/itsleeds/uk2gtfs/) and [pt2matsim](https://github.com/matsim-org/pt2matsim) for public transport (*to be commited*)
 - `Population`: Synthetic population generation using [SPENSER](https://github.com/nismod/microsimulation) and spatialdata for the population; [QUANT model](https://journals.sagepub.com/doi/full/10.1177/0042098020982252) to estimate and sample gravity flows ([spatialdata implementation](https://github.com/openmole/spatialdata/tree/master/library/src/main/scala/org/openmole/spatialdata/application/quant)) (*to be commited*)
 - `Matsim` MATSim model

For OpenMOLE scripts, see current QUANT-SPENSER integration at [../SpenserQuantCoupling](https://github.com/JusteRaimbault/UrbanDynamics/tree/master/Models/SpenserQuantCoupling)


# TODO

## 2021/01/28

 * visu: via https://simunto.com/ - check and explore installed appli Downloads/Via-20.3. pb: paying. => NetLogo for films?

## In progress 2021/01/04

 * Pb convergence in Spenser synthpop (occurs for The City MSOA (?) for example => iterations hardcoded in https://github.com/BenjaminIsaac0111/humanleague/blob/master/src/IPF.h
=> open issue / pull request? ; in https://github.com/nismod/household_microsynth ? / recalrify Spenser synthpop workflow (pop/hosueholds, matching, etc.)

 * vis matsim: otfvis ; see https://github.com/matsim-org/matsim-code-examples/issues/341

 * scenario IDF Matsim https://www.matsim.org/gallery/ile_de_france

 * Integrate public transport: https://itsleeds.github.io/UK2GTFS/reference/transxchange2gtfs.html ; https://www.travelinedata.org.uk/traveline-open-data/traveline-national-dataset/

