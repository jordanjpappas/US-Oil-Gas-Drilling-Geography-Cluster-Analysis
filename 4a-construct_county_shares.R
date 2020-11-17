# Jordan Pappas, Richard DiSalvo
# University of Rochester Medical Center, Princeton University
# jordan.pappas@rochester.edu




# construct a state-level dataset that counts of the number of counties in each cluster by state
  # columns: State, Cluster1, Cluster2, Cluster3...
  # report the share of counties in each cluster by state as one of our tables



# Set directories

.rt_proj <- "/Users/Jordan/Box/ShaleGas/Proj/oldnewdrillingclassify/" # this line for jordan's computer

.rt_data <- paste0(.rt_proj,'data')
.rt_output <- paste0(.rt_proj,'output')


# Load CRAN packages

library(magrittr)
library(dplyr)
library(readr)
library(stringr)
library(reshape2)
library(ggplot2)
library(tidyr)
library(flexmix)
library(tidyverse)
library(haven)


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

# Analysis

df_ls = list(unweightedtmp21,unweightedtmp22,unweightedtmp23,unweightedtmp24,unweightedtmp25,unweightedtmp26,unweightedtmp27,unweightedtmp28,unweightedtmp29,unweightedtmp210,
             weightedtmp21,weightedtmp22,weightedtmp23,weightedtmp24,weightedtmp25,weightedtmp26,weightedtmp27,weightedtmp28,weightedtmp29,weightedtmp210)

county_share_func <-county_share_func <- function (df) {
  res <- df %>% group_by(STATE,clust) %>% summarise(Freq=n())
  newertmp <- dcast(res, STATE ~ clust)
}

county_share_dfs <- lapply(df_ls, county_share_func)

# unweighted 2 and 3 cluster shares, order by the number of drilling counties
x <- county_share_dfs[[1]]
names(x)[2] <- 'Ncounties'
x %<>% left_join(county_share_dfs[[2]], by = 'STATE')
x %<>% left_join(county_share_dfs[[3]], by = 'STATE')
names(x)[3:7] <- c('TwoC1','TwoC2','ThreeC1','ThreeC2','ThreeC3')

x[is.na(x)] <- 0

x %<>% arrange(desc(Ncounties))

stopifnot(all(x$TwoC1 + x$TwoC2 == x$Ncounties))
stopifnot(all(x$ThreeC1 + x$ThreeC2 + x$ThreeC3 == x$Ncounties))
bottomrow <- x %>% summarize_all(list(~sum(.)))

'statetofips.csv' %>% read_csv -> statetofips

x %<>% left_join(select(statetofips,fips,name),by=c('STATE'='fips'))
x %<>% bind_rows(bottomrow)
x$name[nrow(x)] <- 'All States'
x %<>% select(State=name,everything()) %>% select(-STATE)


library(dismisc)
x %<>% mutate_at(vars(TwoC1:ThreeC3), list(~t_td((100*.)/Ncounties,0)))

setwd(.rt_scratch)
x %>% saveRDS('stateclustersummary.rds')



