setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/Matsim/'))

library(sf)
library(dplyr)

fuas <- st_read(paste0(Sys.getenv('CS_HOME'),'/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0.gpkg'))

as.data.frame(fuas[fuas$Cntry_ISO=='GBR',] %>% arrange(desc(FUA_p_2015)))
