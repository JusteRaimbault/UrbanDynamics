
setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/Matsim'))

# remotes::install_github("ITSleeds/UK2GTFS")

#library(UK2GTFS)

source('Network/functions.R')

datadir = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/TNDS/data_20210322/')
targetdir = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/TNDS/gtfs_20210322/')

#transxchange2gtfs(paste0(datadir,'SW.zip'))

areas = c('EA','EM','L','NE', 'NW','S', 'WM', 'SE', 'W')
# 'NCSD' # removed -> failing?
# 'NW' -> fails, relaunched with try_mode=T: fail; relaunch with overriding function: gtfs_merge with force=T
# 'SE', 'W', 'Y': empty -> relaunch
#  'Y' -> fails

for(area in areas){
  show(area)
  gtfs_write(
   gtfs = transxchange2gtfs_forceMerge(paste0(datadir,area,'.zip'),ncores=4, try_mode = T),
   folder = targetdir,
   name=paste0(area,'_gtfs')
  )
}


# merge resulting gtfs
#
#gtfs_write(gtfs=
#  gtfs_merge(gtfs_list = list(
#    gtfs_read(paste0(targetdir,'EA_gtfs.zip')),
#    gtfs_read(paste0(targetdir,'NE_gtfs.zip'))
#  ), force = T),
#  folder = targetdir,
#  name='test_EA-NE'
#)


merge_all_gtfs(targetdir)


# to extract area: gtfs_clip
#library(sf)
# fuafile = paste0(Sys.getenv('CS_HOME'),'/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0.gpkg')
#fuas <-st_transform(st_read(paste0(Sys.getenv('CS_HOME'),'/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0.gpkg')),4326)

#extract_gtfs(fuafile,datadir,'York')

#gtfs_write(
#  gtfs_clip(
#    gtfs_read(paste0(targetdir,'SW_gtfs.zip')),
#    fuas[fuas$eFUA_name=='Exeter',]
#  ),
#  folder = targetdir,
#  name='Exeter'
#)

# test plotting bus lines
#library(dplyr)

#stops <- as.tbl(read.csv(paste0(targetdir,'Exeter/stops.txt')))
#stoptimes <- as.tbl(read.csv(paste0(targetdir,'Exeter/stop_times.txt')))
#
#stoptimes<- left_join(stoptimes,stops[,c('stop_id','stop_lon','stop_lat')])

# peak hours trips

#peakhours = stoptimes[
#c(grep(pattern='07:..:00',x=as.character(stoptimes$arrival_time)),
#  grep(pattern='08:..:00',x=as.character(stoptimes$arrival_time)),
#  grep(pattern='09:..:00',x=as.character(stoptimes$arrival_time))
#),]

#g=ggplot(peakhours,aes(x=stop_lon,y=stop_lat,group=trip_id))
#g+geom_path()



  