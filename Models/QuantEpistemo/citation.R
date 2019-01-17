setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/QuantEpistemo'))

library(dplyr)
library(igraph)

source('functions.R')

edges <- read.csv('data/spatialmicrosim_depth2_links.csv',sep=";",header=F,colClasses = c('character','character'))
nodes <- as.tbl(read.csv('data/spatialmicrosim_depth2.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c('character','character','character')))

names(nodes)<-c("title","id","year")

elabels = unique(c(edges$V1,edges$V2))
empty=rep("",length(which(!elabels%in%nodes$id)))
nodes=rbind(nodes,data.frame(title=empty,id=elabels[!elabels%in%nodes$id],year=empty))#,abstract=empty,authors=empty))

citation <- graph_from_data_frame(edges,vertices = nodes[,c(2,1,3)])#3:7)])
components(citation)$csize

citation = induced_subgraph(citation,which(components(citation)$membership==1))
# IGRAPH 4865d41 DN-- 146774 210341

V(citation)$reduced_title = sapply(V(citation)$title,function(s){paste0(substr(s,1,50),"...")})
V(citation)$reduced_title = ifelse(degree(citation)>20,V(citation)$reduced_title,rep("",vcount(citation)))

citationcore = induced_subgraph(citation,which(degree(citation)>1))

citationcorehigher = citationcore
while(length(which(degree(citationcorehigher)==1))>0){citationcorehigher = induced_subgraph(citationcorehigher,which(degree(citationcorehigher)>1))}

write_graph(citationcore,file='data/spatialmicrosim_core.gml',format = 'gml')
write_graph(citationcorehigher,file='data/spatialmicrosim_corehigher.gml',format = 'gml')


# get network at level 1
initialcorpus = read.csv('data/spatialmicrosim_corpus_spatial+microsimulation.csv',sep=";",colClasses = c('character','character','character'))
V(citation)$initial = V(citation)$name%in%initialcorpus$id
vdepth1=V(citation)[rep(FALSE,length(V(citation)))]
for(id in V(citation)$name[V(citation)$initial]){show(id);vdepth1=append(vdepth1,neighbors(citation,V(citation)$name==id,mode="in"))}
citationd1 =induced_subgraph(citation,vids = V(citation)$name%in%vdepth1$name)
# adjust reduced title degree
V(citationd1)$reduced_title = ifelse(degree(citationd1)>40,V(citationd1)$reduced_title,rep("",vcount(citationd1)))

mean(degree(citationd1,mode = 'in'))

write_graph(citationd1,file='data/spatialmicrosim_depth1.gml',format = 'gml')

vdepth0=V(citation)[V(citation)$initial]
citationd0 = induced_subgraph(citation,vids = vdepth0)
citationd0giant = induced_subgraph(citationd0,which(components(citationd0)$membership==1))

write_graph(citationd0,file='data/spatialmicrosim_depth0.gml',format = 'gml')
write_graph(citationd0giant,file='data/spatialmicrosim_depth0giantcomp.gml',format = 'gml')

mean(degree(citationd0giant,mode = 'in'))

# TODO :
# : separate two graphs ; see communities within each
# : check higher order core (while deg = 1)

##
# size of two subgraphs / export for viz
#id = ""
#V(citation)[V(citation)$name==id]
#incid1=c(V(citation)[V(citation)$name==id],neighbors(citation,V(citation)$name==id,mode="in"))
#for(i in neighbors(citation,V(citation)$name==id,mode="in")){incid1=append(incid1,neighbors(citation,i,mode="in"))}
#write_graph(induced_subgraph(citation,incid1$name),file=paste0('data/',id,'.gml'),format = 'gml')


# density
ecount(citationcore)/(vcount(citationcore)*(vcount(citationcore)-1))

# mean degrees
mean(degree(citation))
mean(degree(citation,mode = 'in'))
mean(degree(citationcore,mode = 'in'))
mean(degree(citationcorehigher,mode = 'in'))


# modularity / vs null model
A=as_adjacency_matrix(citationcore,sparse = T)
M = A+t(A)
undirected_rawcore = graph_from_adjacency_matrix(M,mode="undirected")

# communities
com = cluster_louvain(undirected_rawcore)

directedmodularity(com$membership,A)

nreps = 100
mods = c()
for(i in 1:nreps){
  show(i)
  mods=append(mods,directedmodularity(com$membership,A[sample.int(nrow(A),nrow(A),replace = F),sample.int(ncol(A),ncol(A),replace = F)]))
}

show(paste0(mean(mods)," +- ",sd(mods)))


d=degree(citationcore,mode='in')
for(c in unique(com$membership)){
  show(paste0("Community ",c, " ; corpus prop ",length(which(com$membership==c))/vcount(undirected_rawcore)))
  #show(paste0("Size ",length(which(com$membership==c))))
  currentd=d[com$membership==c];dth=sort(currentd,decreasing = T)[10]
  show(data.frame(titles=V(citationcore)$title[com$membership==c&d>dth],degree=d[com$membership==c&d>dth]))
  #show(V(rawcore)$title[com$membership==c])
}


