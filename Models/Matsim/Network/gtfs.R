
setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/Matsim'))

# remotes::install_github("ITSleeds/UK2GTFS")

library(UK2GTFS)

transxchange2gtfs(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/TNDS/data_20210322/SW.zip'))

gtfs_write(
 gtfs = transxchange2gtfs(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/TNDS/data_20210322/EA.zip'),ncores=4),
 folder = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/TNDS/data_20210322'),
 name='EA_gtfs'
)
