
setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/Matsim'))

# remotes::install_github("ITSleeds/UK2GTFS")

library(UK2GTFS)

datadir = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/TNDS/data_20210322/')
targetdir = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/TNDS/gtfs_20210322/')

#transxchange2gtfs(paste0(datadir,'SW.zip'))

#areas = c('EA','EM','L')
# 'NCSD'
areas = c('NE','NW','S','SE','SW','W','WM','Y')

for(area in areas){
  show(area)
  gtfs_write(
   gtfs = transxchange2gtfs(paste0(datadir,area,'.zip'),ncores=4),
   folder = targetdir,
   name=paste0(area,'_gtfs')
  )
}
  