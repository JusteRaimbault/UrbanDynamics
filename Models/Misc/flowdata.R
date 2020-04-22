
setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/Misc'))

library(dplyr)
library(Matrix)

datadir = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/QUANT/occupation/')
resdir = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Results/UKFlows/')

# occupation flows
occupflowssparse <- as.tbl(read.csv(paste0(datadir,'occupationTripsNOmode.csv')))

# length(unique(occupflowssparse$Origin))
# length(unique(occupflowssparse$Destination)) # -> too much destination msoa?
orig = unique(occupflowssparse$Origin)
dest = unique(occupflowssparse$Destination)
outsidedest = dest[!dest%in%orig] # -> these seem to be Nothern Ireland lsoa

# flows between GB and NI
100*sum(occupflowssparse$OccupationAll[occupflowssparse$Destination%in%outsidedest&(!occupflowssparse$Origin%in%outsidedest)])/sum(occupflowssparse$OccupationAll)
# = 0.01455209% - totally negligible

# flows to NI # -> same - no NI in origin
#100*sum(occupflowssparse$OccupationAll[occupflowssparse$Destination%in%outsidedest])/sum(occupflowssparse$OccupationAll)

occupflowssparse = occupflowssparse[occupflowssparse$Destination%in%orig,]

# sparsity 
nrow(occupflowssparse)/length(orig)^2 # = 0.03658215, quite sparse

# to construct the sparse matrix, use same indexation as distance and mode flows matrices
zones <- as.tbl(read.csv(paste0(datadir,'../converted/EWS_ZoneCodes.csv')))
zoneind = zones$zonei;names(zoneind)<-zones$areakey

occupflows = sparseMatrix(i=zoneind[as.character(occupflowssparse$Origin)],j=zoneind[as.character(occupflowssparse$Destination)],x=occupflowssparse$OccupationAll,dims=c(length(orig),length(orig)),index1 = F)


# mode flows
roadsparse = read.csv(file = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/QUANT/converted/TObs_1.csv'),header=F,skip = 1)
roadflows = sparseMatrix(i=roadsparse$V1,j=roadsparse$V2,x=roadsparse$V3,dims=dim(occupflows),index1 = F)

railsparse = read.csv(file = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/QUANT/converted/TObs_2.csv'),header=F,skip = 1)
railflows = sparseMatrix(i=railsparse$V1,j=railsparse$V2,x=railsparse$V3,dims=dim(occupflows),index1 = F)

bussparse = read.csv(file = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/QUANT/converted/TObs_3.csv'),header=F,skip = 1)
busflows = sparseMatrix(i=bussparse$V1,j=bussparse$V2,x=bussparse$V3,dims=dim(occupflows),index1 = F)


# missing mode flows
1 - sum(roadflows+railflows+busflows) / sum(occupflows) 
1 - sum(diag(roadflows)+diag(railflows)+diag(busflows)) / sum(diag(occupflows))

softflows = occupflows - (roadflows+railflows+busflows)
summary(unlist(softflows)@x)
# -> ??? - not consistent, should never be negative
quantile(unlist(softflows)@x,c(0.01))
outid = which(softflows==min(softflows),arr.ind = T)[1]
softflows[softflows==min(softflows)]
zones[outid,]
occupflows[outid,outid] - roadflows[outid,outid] - railflows[outid,outid] - busflows[outid,outid]
softflows[outid,outid]
rmin = apply(softflows,1,min)
outrow=which(rmin==min(rmin))
rowmin = softflows[outrow,];outcol=which(rowmin==min(rowmin))
softflows[outrow,outcol]
occupflows[outrow,outcol];roadflows[outrow,outcol];railflows[outrow,outcol];busflows[outrow,outcol]


# !!! these flows are not consistent -> use occupationMODE
occupmodes <- as.tbl(read.csv(paste0(datadir,'occupationBus.csv'),header = F))
names(occupmodes)<- c('Origin','Destination','ObsAllSixModes','O1','O2','O3','O4','O5','O6','O7','O8','O9',
                      'ObsRoad','ObsBus','ObsRail','%RoadfromTotal','AdjO1','AdjO2','AdjO3','AdjO4','AdjO5','AdjO6','AdjO7','AdjO8','AdjO9')

# check that total is the same
occupflows2 = sparseMatrix(i=zoneind[as.character(occupmodes$Origin)],j=zoneind[as.character(occupmodes$Destination)],x=occupmodes$ObsAllSixModes,dims=c(length(orig),length(orig)),index1 = F)
sum(occupflows - occupflows2) # weird !

# list of flows by occupation
alloccupflows = list()
for(occup in c('O1','O2','O3','O4','O5','O6','O7','O8','O9')){
  alloccupflows[[occup]] = sparseMatrix(i=zoneind[as.character(occupmodes$Origin)],j=zoneind[as.character(occupmodes$Destination)],x=occupmodes[[occup]],dims=c(length(orig),length(orig)),index1 = F)
  alloccupflows[[occup]][which(is.na(alloccupflows[[occup]]))]=0
}

sum(sapply(alloccupflows,sum));sum(occupflows2)
# -> some commuter missing in all six modes compared to sum of all occupations: add missing mode? remove proportionally?
# ! no distinction walking/bike

allmodesflows = list()
for(mode in c('Road','Bus','Rail')){
  allmodesflows[[mode]]=sparseMatrix(i=zoneind[as.character(occupmodes$Origin)],j=zoneind[as.character(occupmodes$Destination)],x=occupmodes[[paste0('Obs',mode)]],dims=c(length(orig),length(orig)),index1 = F)
  allmodesflows[[mode]][which(is.na(allmodesflows[[mode]]))]=0
}
allmodesflows[['Soft']]=sparseMatrix(i=zoneind[as.character(occupmodes$Origin)],j=zoneind[as.character(occupmodes$Destination)],x=occupmodes$ObsAllSixModes-occupmodes$ObsRoad-occupmodes$ObsBus-occupmodes$ObsRail,dims=c(length(orig),length(orig)),index1 = F)
allmodesflows[['Soft']][which(is.na(allmodesflows[['Soft']]))]=0
#sapply(allmodesflows,function(m){length(which(is.na(m)))})

# export sparse mat for Quant


###
# correlation: raw correlation matrices
library(corrplot)

rho=matrix(0,length(allmodesflows),length(alloccupflows));rownames(rho)=names(allmodesflows);colnames(rho)=names(alloccupflows)
rhomin=matrix(0,length(allmodesflows),length(alloccupflows));rownames(rhomin)=names(allmodesflows);colnames(rhomin)=names(alloccupflows)
rhomax=matrix(0,length(allmodesflows),length(alloccupflows));rownames(rhomax)=names(allmodesflows);colnames(rhomax)=names(alloccupflows)

for(occup in names(alloccupflows)){for(mode in names(allmodesflows)){
  show(paste0(occup," ",mode))
  test = cor.test(as.vector(alloccupflows[[occup]]),as.vector(allmodesflows[[mode]]))
  rho[mode,occup]=test$estimate;rhomin[mode,occup]=test$conf.int[1];rhomax[mode,occup]=test$conf.int[2]
}}

png(filename=paste0(resdir,'corr-raw.png'),width = 15,height=10,units = 'cm',res=300)
corrplot(rho,lowCI.mat=rhomin,uppCI.mat=rhomax)
dev.off()

# correlations between local proportions?
#(in absolute value linear corr does not make sense, flows are far from normally distributed)
#  - between log of flows? + selection model for zeros?

for(occup in names(alloccupflows)){for(mode in names(allmodesflows)){
  show(paste0(occup," ",mode))
  test = cor.test(as.vector(log(1 + alloccupflows[[occup]])),as.vector(log(1+allmodesflows[[mode]])))
  rho[mode,occup]=test$estimate;rhomin[mode,occup]=test$conf.int[1];rhomax[mode,occup]=test$conf.int[2]
}}
png(filename=paste0(resdir,'corr-log.png'),width = 15,height=10,units = 'cm',res=300)
corrplot(rho,lowCI.mat=rhomin,uppCI.mat=rhomax)
dev.off()

# proportions

totmode = Reduce("+",allmodesflows)
totoccup = Reduce("+",alloccupflows)
for(occup in names(alloccupflows)){for(mode in names(allmodesflows)){
  show(paste0(occup," ",mode))
  x = as.vector(alloccupflows[[occup]]/totoccup);y=as.vector(allmodesflows[[mode]]/totmode)
  x[is.nan(x)]=0;y[is.nan(y)]=0
  test = cor.test(x,y)
  rho[mode,occup]=test$estimate;rhomin[mode,occup]=test$conf.int[1];rhomax[mode,occup]=test$conf.int[2]
}}
png(filename=paste0(resdir,'corr-prop.png'),width = 15,height=10,units = 'cm',res=300)
corrplot(rho,lowCI.mat=rhomin,uppCI.mat=rhomax)
dev.off()






