# Richard DiSalvo, Jordan Pappas
# Princeton University, University of Rochester Medical Center
# jordan.pappas@rochester.edu





# Mixed Models Analysis



# Import data

setwd(.rt_data)

spudsbyyear <- readRDS('nationalwellsbycountyyear.rds')
countyareas <- readRDS("county_data.rds")


spudsbyyear <- spudsbyyear_new



# Preamble

  # countyareas
  
  countyareas$sqkm <- countyareas$acreage/247
  countyareas$county_name <- countyareas$state_fips <- countyareas$sh_acreage <- countyareas$state_ab <- 
    countyareas$sh_perc <- countyareas$acreage <- NULL
  countyareas <- complete(countyareas)

  # spudsbyyear

    # spudyear
    names(spudsbyyear)[names(spudsbyyear)=="spud_year"] <- "spudyear"
    spudsbyyear$spudyear %<>% as.numeric
    spudsbyyear %<>% group_by(STATE,COUNTY) %>% complete(spudyear = 1990:2019)
    spudsbyyear %<>% filter(spudyear %in% 1990:2019)
    spudsbyyear %<>% filter(STATE!=0)
    spudsbyyear %<>% filter(spudyear>=2000)
    
    # nspuds
    #spudsbyyear$nspuds <- spudsbyyear$nspudsweighted2pt7
    spudsbyyear$nspudsweighted2pt7 <- NULL
    spudsbyyear$nspuds[is.na(spudsbyyear$nspuds)] <- 0
    spudsbyyear$nspuds %<>% round(0)
    
    # totalnspuds
    spudsbyyear %<>% group_by(STATE,COUNTY) %>% mutate(
      totalnspuds = sum(nspuds)
    )
    
    # stcounty_fip
    spudsbyyear$stcounty_fip <- paste0(spudsbyyear$STATE,spudsbyyear$COUNTY)
    spudsbyyear <- complete(spudsbyyear)



# Merge data

spudsbyyear <- left_join(spudsbyyear,countyareas,by=c('stcounty_fip'='county_fips_code'))
spudsbyyear$stcounty_fip <- NULL

  # sqkm
  spudsbyyear$totalnspudssqkm <- spudsbyyear$totalnspuds/spudsbyyear$sqkm
  stopifnot(sum(is.na(spudsbyyear$nspuds))==0)



# Filter 5% of total wells

spudsbyyear %>% dplyr::select(STATE,COUNTY,totalnspuds) %>% distinct -> spudsbyyear_grouped
stopifnot(nrow(spudsbyyear_grouped) == nrow(distinct(spudsbyyear_grouped,STATE,COUNTY))) # make sure state and county uniquely identify rows after that above distinct()

spudsbyyear_grouped %<>% filter(totalnspuds>0)

finalnspuds <- sum(spudsbyyear_grouped$totalnspuds)

spudsbyyear_grouped$pernspuds <- spudsbyyear_grouped$totalnspuds/finalnspuds
spudsbyyear_grouped <- spudsbyyear_grouped %>% arrange(pernspuds)

spudsbyyear_grouped <- within(spudsbyyear_grouped, acc_sum <- cumsum(pernspuds))

spudsbyyear_grouped <- spudsbyyear_grouped[!(spudsbyyear_grouped$acc_sum < .05),]
spudsbyyear_grouped$id <- paste0(spudsbyyear_grouped$STATE,spudsbyyear_grouped$COUNTY)
avector <- as.vector(spudsbyyear_grouped$id)

spudsbyyear$id <- paste0(spudsbyyear$STATE,spudsbyyear$COUNTY)

# check that it is 5% and get the cutoff
spudsbyyear_todrop <- spudsbyyear[!(spudsbyyear$id %in% avector),]
spudsbyyear_tokeep <- spudsbyyear[spudsbyyear$id %in% avector,]
(spudsbyyear_todrop$nspuds %>% sum) / ((spudsbyyear_tokeep$nspuds %>% sum) + (spudsbyyear_todrop$nspuds %>% sum)) 
spudsbyyear_todrop$totalnspuds %>% max
spudsbyyear_tokeep$totalnspuds %>% min

spudsbyyear_tokeep %>% group_by(STATE,COUNTY) %>% summarize() %>% nrow()
spudsbyyear %>% group_by(STATE,COUNTY) %>% summarize() %>% nrow()

spudsbyyear <- spudsbyyear[spudsbyyear$id %in% avector,]

write_csv(tibble(countyid=avector),'analyticsample_countyids.csv')

write_csv(tibble(countyid=avector),'analyticsample_countyids_spuds.csv')



# Build tmpmat (with shares) and tots (for total levels)

spudsbyyear %>% distinct(STATE,COUNTY,totalnspuds) -> tots

setwd(.rt_data)
spudsbyyear %>% mutate(
  y = nspuds/totalnspuds,
  y = coalesce(y,0)
) %>% dplyr::select(STATE,COUNTY,spudyear,y) %>% write_csv('spudsbyyear.csv')

tmp <- spudsbyyear %>% mutate(spudyear = paste0('y',spudyear)) %>% 
  dcast(STATE + COUNTY ~ spudyear, value.var = 'nspuds')
tmp[is.na(tmp)] <- 0
stopifnot(all(tmp$STATE==tots$STATE) & all(tmp$COUNTY==tots$COUNTY))

tmpmat <- as.matrix(dplyr::select(tmp,-STATE,-COUNTY))

tots <- tots$totalnspuds
tmpmat <- tmpmat/tots

stopifnot(all(tmpmat %>% rowSums == 1)) # rows should be shares in the same county

tmpmat <- tmpmat[,-ncol(tmpmat)] # remove last column (year "T" in the paper) because of linear dependence!

setwd(.rt_data)
write.csv(tmpmat,'tmpmat.csv')


# Analysis

# define flexmix driver for fixed-effects poisson regression (see methods section of paper, this is a modification of flexmix::FLXMCmvpois())
FLXMCfepois <- function (formula = . ~ .) 
{
  z <- new("FLXMC", weighted = TRUE, formula = formula, 
           dist = "FEpoisson", name = "model-based Poisson FE Clustering")
  z@preproc.y <- function(x) {
    # storage.mode(x) <- "integer"
    x
  }
  z@defineComponent <- function(para) {
    logLik <- function(x, y) {
      # browser()
      # colSums(dpois(t(y), para$lambda, log = TRUE))
      ns <- x[,2] # capture the totals by county
      l <- para$lambda # capture the lambdas
      expanded_L <- outer(l,ns) # these are the cell-specific lambdas. 
      
      colSums(dpois(t(ns*y), expanded_L, log = TRUE)) # note that the the params lambda are p's, shares, not means. thus expanded_L is used to make this poisson distributed comp-by-comp
    }
    
    new("FLXcomponent", parameters = list(lambda = para$lambda), 
        df = para$df, logLik = logLik) # , predict = predict
    }
  z@fit <- function(x, y, w, ...) {

    z@defineComponent(list(lambda = colSums(w * y * x[,2])/sum(w * x[,2]),
                           df = ncol(y))) # this is the correct MLE step based on maximization of the poisson loglik using calculus
  }
  z
  }
  


# Poisson FE finite Mixture Model loop

maxNclust <- 3


for (w in c('weighted','unweighted')){


  setwd(.rt_output)
  
  png(paste0(w,'ClusterPlot.png'),width=2000,height=1200)
  par(mar=c(5,4,4,2), mfrow=c(maxNclust,maxNclust),adj=.5)
  
  
  for (i in 1:maxNclust){ #5
    
    # Fit model
    
    set.seed(12345)
    if(w == 'unweighted') {
      poisson_mm <- stepFlexmix(tmpmat ~ tots, 
                            k = i,
                            model = FLXMCfepois(),
                            control = list(tolerance = 1e-15,iter.max = 10000,minprior = 0),nrep = 100)
    } else if(w == 'weighted') {
      poisson_mm <- stepFlexmix(tmpmat ~ tots, 
                            k = i,
                            model = FLXMCfepois(),
                            control = list(tolerance = 1e-15,iter.max = 10000,minprior = 0),
                            weights = as.integer(tots),nrep = 100)
    }
  
    params_mus <- data.frame(parameters(poisson_mm))
    
    # Add year column
    
    params_mus_years <- params_mus %>% 
      mutate(year = colnames(tmpmat))
    
    # Rearrange clusters data frame based on the year of the maximum lambda 
    
    year <- c(2000:2019)
    year <- sub("^", "y", year )
    params_lambdas_years_new <- data.frame(year)
    
    dtmp <- NULL
    for (j in 1:i){
      
      params_lambdas_years_max <- params_mus_years[which.max(as.numeric(params_mus_years[[j]])),]
      max_year <- params_lambdas_years_max$year
      new_max <- rbind(params_mus_years[j], as.numeric(str_extract(max_year,pattern='[0-9]+')))
      
      dtmp %<>% bind_cols(new_max)
      }
  
    dtmp <- dtmp[,order(dtmp[nrow(dtmp),]),drop=FALSE]
    dtmp <- dtmp[-nrow(dtmp),,drop=FALSE]
    hashmapcluster_old2new <- setNames(1:i,nm = names(dtmp)) # use this to relabel the clusters later on
    names(dtmp) <- 1:i
    dtmp$year <- 2000:2018
    dtmp %<>% melt(id.vars='year')
    names(dtmp) <- c('year','cluster','lambdas')
    
    # Plot the clusters with their lambdas
      # find max of each comp column and select year from that row
      # then order the comps by the year
    
    setwd(.rt_data)
    write.csv(dtmp,paste0(w,i,'dtmp.csv'))
    setwd(.rt_output)
    
    plotdata2 <- dtmp
     
    # add in the last year p_kT (called lambda in the code) for each cluster k
    plotdata2 %>% group_by(cluster) %>% summarize(
      lambdas = 1-sum(lambdas)
    ) %>% ungroup %>% mutate(
      year = 2019 # last year of the data, year T, excluded from estimation
    ) -> toadd
    plotdata2 %<>% bind_rows(toadd)
    plotdata2 %<>% arrange(cluster, year)
    
    setwd(.rt_output)
  
    
    for (clust in 1:maxNclust){
      plotdata2clust <- plotdata2[plotdata2$cluster == clust, ]
      if (clust <= i) {
        cex = 3
        plot(plotdata2clust$year, plotdata2clust$lambdas, type = "l", ylim=c(0, .15), xlab = '', ylab = '', xaxt='n', yaxt='n')
        ticks_x = c(2000, 2005, 2010, 2015, 2019)
        ticks_y = c(0.00, 0.05, 0.10, 0.15)
        axis(side = 1, at = ticks_x, cex.axis=2.3)
        axis(side = 2, at = ticks_y, cex.axis=2.3)
        abline(v=2007, col="black")
      } else {
        plot.new()
      }
    }
    
    #ggsave(temp_plot, file=paste0("fepoisson_clusterplot", i,".png"))
    
  
    
    # Export RDS for mapping
    
    tmp$clust <- clusters(poisson_mm)
    tmp %>% dplyr::select(STATE,COUNTY,clust) -> tmp2
    tmp2$clust %<>% {paste0('Comp.',.)}
    tmp2$clust <- hashmapcluster_old2new[tmp2$clust]
    
    setwd(.rt_output)
  
    tmp2 %>% saveRDS(paste0('spuds',w,i,'fepoisson_clusters.rds'))
    setwd(.rt_data)
    write.csv(tmp2,paste0(w,i,'tmp2.csv'))
    setwd(.rt_output)


}

dev.off()

}





