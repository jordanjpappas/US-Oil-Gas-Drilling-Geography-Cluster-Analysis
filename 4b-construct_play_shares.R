# Jordan Pappas, Richard DiSalvo
# University of Rochester Medical Center, Princeton University
# jordan.pappas@rochester.edu





# Set directories

.rt_proj <- "/Users/Jordan/Box/ShaleGas/Proj/oldnewdrillingclassify/" # this line for jordan's computer

.rt_data <- paste0(.rt_proj,'data')
.rt_output <- paste0(.rt_proj,'output')
.rt_scratch <- paste0(.rt_proj,'scratch')


# Load CRAN packages

library(magrittr)
library(raster)
library(dplyr)
library(readr)
library(stringr)
library(reshape2)
library(ggplot2)
library(tidyr)
library(flexmix)
library(tidyverse)
library(haven)
#library(sp)
library(rgdal)
library(maptools)
library(rgeos)
library(sf)



# Import data

setwd(.rt_data)

unweightedtmp21 = read.csv('unweighted1tmp2.csv')
unweightedtmp22 = read.csv('unweighted2tmp2.csv')
unweightedtmp23 = read.csv('unweighted3tmp2.csv')
unweightedtmp24 = read.csv('unweighted4tmp2.csv')
unweightedtmp25 = read.csv('unweighted5tmp2.csv')
unweightedtmp26 = read.csv('unweighted6tmp2.csv')
unweightedtmp27 = read.csv('unweighted7tmp2.csv')
unweightedtmp28 = read.csv('unweighted8tmp2.csv')
unweightedtmp29 = read.csv('unweighted9tmp2.csv')
unweightedtmp210 = read.csv('unweighted10tmp2.csv')

weightedtmp21 = read.csv('weighted1tmp2.csv')
weightedtmp22 = read.csv('weighted2tmp2.csv')
weightedtmp23 = read.csv('weighted3tmp2.csv')
weightedtmp24 = read.csv('weighted4tmp2.csv')
weightedtmp25 = read.csv('weighted5tmp2.csv')
weightedtmp26 = read.csv('weighted6tmp2.csv')
weightedtmp27 = read.csv('weighted7tmp2.csv')
weightedtmp28 = read.csv('weighted8tmp2.csv')
weightedtmp29 = read.csv('weighted9tmp2.csv')
weightedtmp210 = read.csv('weighted10tmp2.csv')

statetofips = read.csv('statetofips.csv')

SHP1 <- st_read('ShalePlays_US_EIA_Sep2019.shp')
SHP2 <- st_read('cb_2018_us_county_within_cd116_500k.shp')


# SF Join

SHP1 <- SHP1 %>% st_transform(3857)
SHP2 <- SHP2 %>% st_transform(3857)

SHP1 <- st_set_crs(SHP1, 3857)
SHP2 <- st_set_crs(SHP2, 3857)

# add the land area of the shape of the county
SHP2$area <- sf::st_area(SHP2)

# for each county take max land area
SHP2 %<>% group_by(STATEFP,COUNTYFP) %>% mutate(
  maxlandarea = (area == max(area))
) %>% filter(maxlandarea) %>% ungroup

SHP2 %>% group_by(STATEFP,COUNTYFP) %>% summarize(nrow=n()) %$% table(nrow) # looks good, unique now!


SHP2$centroids <- st_centroid(SHP2$geometry)


# rd note 2020-08-01 -- weird, geometries aren't unique by state & countyfp. added a distinct() below, applied to county_play_df, let's see if that works
SHP2  %>% group_by(STATEFP,COUNTYFP) %>% summarize(nrow=n()) %$% table(nrow)

SHP_merged <- st_intersects(SHP2$centroids, SHP1)

# SHP_merged is a list of lists, gives indices of all the plays the point (centroid of the county) falls into
# best way to unlist it is to take the first entry of each as follows
# SHP_merged <- sapply(SHP_merged, function(x) { ifelse(length(x)>0,x[[1]],NA) })

# rd 2020-08-1 -- better version
SHP_merged <- lapply(1:length(SHP_merged), function(i) { 
  data_frame(i,playindices=unlist(SHP_merged[[i]]))
  } 
 )
SHP_merged %<>% bind_rows()


# add play to each county
# SHP2$Shale_play <- SHP1[unlist(SHP_merged),]$Shale_play
SHP2$i <- 1:nrow(SHP2)
SHP2 %<>% left_join(SHP_merged)
SHP2 %<>% dplyr::select(-i)

SHP2$Shale_play <- SHP1[SHP2$playindices,]$Shale_play

SHP2$Shale_play %>% table(useNA='a')



# Wrangle data
county_play_df <- SHP2

county_play_df$STATEFP <- gsub("(^|[^0-9])0+", "\\1", county_play_df$STATEFP, perl = TRUE)
county_play_df$COUNTYFP <- gsub("(^|[^0-9])0+", "\\1", county_play_df$COUNTYFP, perl = TRUE)

county_play_df$STATEFP <- as.numeric(county_play_df$STATEFP)
county_play_df$COUNTYFP <- as.numeric(county_play_df$COUNTYFP)

# county_play_df$Shale_play %<>% coalesce('ZZ No Play')
county_play_df$Shale_play <- as.factor(county_play_df$Shale_play)



# Merge clusters

county_share_func <- function (df) {
  df <- df %>% left_join(county_play_df,by=c('STATE'='STATEFP','COUNTY'='COUNTYFP')) 
  tmp <- df %>% group_by(Shale_play,clust) %>% summarise(Freq=n())
  final_df <- dcast(tmp, Shale_play ~ clust)
}

df_ls = list(unweightedtmp21,unweightedtmp22,unweightedtmp23,unweightedtmp24,unweightedtmp25,unweightedtmp26,unweightedtmp27,unweightedtmp28,unweightedtmp29,unweightedtmp210,
             weightedtmp21,weightedtmp22,weightedtmp23,weightedtmp24,weightedtmp25,weightedtmp26,weightedtmp27,weightedtmp28,weightedtmp29,weightedtmp210)


county_share_dfs <- lapply(df_ls, county_share_func)





# unweighted 2 and 3 cluster shares, order by the number of drilling counties
x <- county_share_dfs[[1]]
names(x)[2] <- 'Ncounties'
x %<>% left_join(county_share_dfs[[2]], by = 'Shale_play')
x %<>% left_join(county_share_dfs[[3]], by = 'Shale_play')
names(x)[3:7] <- c('TwoC1','TwoC2','ThreeC1','ThreeC2','ThreeC3')

x$Shale_play <- as.character(x$Shale_play)
x$Shale_play[is.na(x$Shale_play)] <- 'No Play'
x[is.na(x)] <- 0
x$Shale_play <- as.factor(x$Shale_play)

x %<>% arrange(desc(Ncounties))

stopifnot(all(x$TwoC1 + x$TwoC2 == x$Ncounties))
stopifnot(all(x$ThreeC1 + x$ThreeC2 + x$ThreeC3 == x$Ncounties))

bottomrow <- x %>% summarize_at(vars(-Shale_play),list(~sum(.)))
x %<>% bind_rows(bottomrow)
x$Shale_play <- as.character(x$Shale_play)
x$Shale_play[nrow(x)] <- 'All County-Play Combinations'
x$Shale_play <- as.factor(x$Shale_play)



library(dismisc)
x %<>% mutate_at(vars(TwoC1:ThreeC3), list(~t_td((100*.)/Ncounties,0)))

x %<>% mutate(
  Ncounties = ifelse(Shale_play %in% c('All County-Play Combinations','No Play'),-Ncounties,Ncounties)
)

x %<>% arrange(desc(Ncounties))

x %<>% mutate(
  Ncounties = ifelse(Shale_play %in% c('All County-Play Combinations','No Play'),-Ncounties,Ncounties)
)

setwd(.rt_scratch)
x %>% saveRDS('playclustersummary.rds')
