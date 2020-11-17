# Jordan Pappas, Richard DiSalvo
# University of Rochester Medical Center, Princeton University
# jordan.pappas@rochester.edu





# Mapping Clusters



# Load packages

library(magrittr)
library(dplyr)
library(tidyr)
library(sp)
library(rgdal)
library(maptools)
library(raster)
library(rgeos)

# Set directory

.rt_proj <- "/Users/Jordan/Box/ShaleGas/Proj/oldnewdrillingclassify/"
#.rt_proj <- 'D:/Box Sync/ShaleGas/Proj/oldnewdrillingclassify/'

.rt_data <- paste0(.rt_proj,'data')
.rt_output <- paste0(.rt_proj,'output')



# State Cluster Plots

for (d in c('spuds','production')){

for (w in c('weighted','unweighted')){

for (state in c('All','Texas','Penn')){

png(paste0(d,w,state,'ClusterMap.png'),width=2000,height=1200)

par(mar=c(5,4,4,2), mfrow=c(3,3),adj=.5)

for (i in 1:3){
print(i)
for (j in 1:3){
print(j)
  
# Import data

setwd(.rt_data)
SHP <- raster::shapefile('cb_2018_us_county_within_cd116_500k.shp')
SHP2 <- raster::shapefile('cb_2018_us_state_20m.shp')

setwd(.rt_output)
clusters <- readRDS(paste0(d,w,i,'fepoisson_clusters.rds'))

# Clean data

  # SHP
  if (state == 'All') { 
    SHP <- SHP[!SHP$STATEFP %in% c('02',15,60,66,69,72,78), ]
  } else if (state == 'Texas') {
    SHP <- SHP[SHP$STATEFP %in% c(48,35,40,'05',22,20,'08'), ]
  } else if (state == 'Penn') {
    SHP <- SHP[SHP$STATEFP %in% c(42,36,34,10,24,54,39), ]
  } else {
    SHP <- SHP
  }
  SHP@data$GEOID <- paste0(SHP@data$STATEFP,SHP@data$COUNTYFP)
  SHP@data$GEOID <- as.numeric(as.character(SHP@data$GEOID))
  SHP@data$GEOID <- as.numeric(SHP@data$GEOID)
  
  # SHP2
  if (state == 'All') { 
    SHP2 <- SHP2[!SHP2$NAME %in% c('Alaska','Hawaii'), ]
  } else if (state == 'Texas') {
    SHP2 <- SHP2[SHP2$NAME %in% c('Texas','New Mexico', 'Oklahoma', 'Arkansas','Louisiana','Kansas','Colorado'), ]
  } else if (state == 'Penn') {
    SHP2 <- SHP2[SHP2$NAME %in% c('Pennsylvania','New York','New Jersey','Delaware','Maryland','West Virginia','Ohio'), ]
  } else {
    SHP2 <- SHP2
  }
  SHP2 <- spTransform(SHP2,raster::crs(SHP))

  # clusters
  clusters$FIPS <- paste0(clusters$STATE,clusters$COUNTY)
  clusters$FIPS <- as.numeric(clusters$FIPS)

# Join data
SHP_clusters <- sp::merge(SHP, clusters,by.x = "GEOID", by.y = "FIPS")
spdf <- SHP_clusters

# Plot data

spdf$fillcolor <- NA
spdf$fillcolor <- ifelse(spdf$clust %in% j, 'black', 'white') 
spdf$fillcolor[is.na(spdf$fillcolor)] <- 'white'
spdf@data$clust[is.na(spdf@data$clust)] <- 0

setwd(.rt_output)

plot(spdf, col = spdf$fillcolor, lwd = 0.001, border=NA)
if ('black' %in% spdf$fillcolor) {
  plot(SHP2, border='black', lwd = 1, add=TRUE) 
}

}

}

dev.off()

}
  
}

}



