# Jordan Pappas, Richard DiSalvo
# University of Rochester Medical Center, Princeton University
# jordan.pappas@rochester.edu





# Create a dataset of counties or county-years with a categorical var for missingness

for (dataset in c("all","cutoff")) {

# Import data

  # comparing countyprod to spudbyyear
  
  setwd(.rt_data)
  library(sf)
  SHP <- sf::st_read('cb_2018_us_county_within_cd116_500k.shp')
  
  
  spudsbyyear <- readRDS('nationalwellsbycountyyear.rds')
  countyprod <- readRDS('countyprod.rds')

  spudsbyyear <- subset(spudsbyyear, spud_year >= 2000)
  countyprod <- subset(countyprod, year >= 2000)
  
  spudsbyyear$geoid <- paste0(spudsbyyear$STATE,spudsbyyear$COUNTY)
  spudsbyyear$geoid <- as.numeric(spudsbyyear$geoid)
  
  dismisc::confirm_ids(spudsbyyear,geoid,spud_year)
  dismisc::confirm_ids(countyprod,county_id,year)
  
  
  
  if (dataset == "cutoff") {
    
    
  # spudsbyyear
    
  spudsbyyear %<>% group_by(STATE,COUNTY) %>% mutate(
      totalnspuds = sum(nspuds)
    )
  
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
  
  spudsbyyear$geoid <- as.numeric(spudsbyyear$geoid)
  
  spudsbyyear_new <- spudsbyyear[spudsbyyear$id %in% avector,]
  
  
  
  # countyprod
  
  # Scale down BOE to 10000s, and round
  countyprod$BOE <- round(countyprod$BOE/10000,0)
  
  # Convert countyprod to spudsbyyear
  countyprod$STATE <- substr(countyprod$county_id,0,2)
  countyprod$COUNTY <- substr(countyprod$county_id,3,5)
  countyprod$spud_year <- countyprod$year
  countyprod$nspuds <- countyprod$BOE
  countyprod$nspudsweighted2pt7 <- countyprod$BOE
  
  countyprod$county_id <- countyprod$year <- countyprod$BOE <- NULL
  
  spudsbyyear <- countyprod
  
  spudsbyyear %<>% group_by(STATE,COUNTY) %>% mutate(
    totalnspuds = sum(nspuds)
  )
  
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
  
  spudsbyyear$county_id <- paste0(spudsbyyear$STATE,spudsbyyear$COUNTY)
  
  # check that it is 5% and get the cutoff
  spudsbyyear_todrop <- spudsbyyear[!(spudsbyyear$county_id %in% avector),]
  spudsbyyear_tokeep <- spudsbyyear[spudsbyyear$county_id %in% avector,]
  (spudsbyyear_todrop$nspuds %>% sum) / ((spudsbyyear_tokeep$nspuds %>% sum) + (spudsbyyear_todrop$nspuds %>% sum))
  spudsbyyear_todrop$totalnspuds %>% max
  spudsbyyear_tokeep$totalnspuds %>% min
  
  spudsbyyear_tokeep %>% group_by(STATE,COUNTY) %>% summarize() %>% nrow()
  spudsbyyear %>% group_by(STATE,COUNTY) %>% summarize() %>% nrow()
  
  spudsbyyear <- spudsbyyear[spudsbyyear$county_id %in% avector,]
  
  spudsbyyear$county_id <- as.numeric(spudsbyyear$county_id)
  
  spudsbyyear$year <- spudsbyyear$spud_year
  spudsbyyear$BOE <- spudsbyyear$nspuds
  
  countyprod_new <- spudsbyyear
  
  spudsbyyear <- spudsbyyear_new
  countyprod <- countyprod_new

  }
  
  
  # keep only counties with actual production and wells (not all zeroes)
  spudsbyyear %<>% group_by(geoid) %>% mutate(
    everdrill = any(nspuds>0)
  ) %>% ungroup
  countyprod %<>% group_by(county_id) %>% mutate(
    everprod = any(BOE>0) #, | any(is.na(BOE)),
  ) %>% ungroup
  
  countyprod$everprod %>% table
  countyprod %>% filter(everprod) %$% unique(county_id) %>% length
  countyprod %>% filter(!everprod) %$% unique(county_id) %>% length
  countyprod$county_id %>% unique %>% length
  
  spudsbyyear %<>% filter(everdrill)
  countyprod %<>% filter(everprod)
  
  spudsbyyear$spud_year %<>% as.numeric
  joined <- full_join(spudsbyyear,countyprod,by=c('geoid'='county_id','spud_year'='year'))
  
  joined$everdrill %<>% coalesce(FALSE)
  joined$everprod %<>% coalesce(FALSE)
  
  joined %<>% group_by(geoid) %>% mutate(
    everdrill = any(everdrill),
    everprod = any(everprod)
  ) %>% ungroup
  
  joined$STATE <- joined$COUNTY <- NULL
  
  joined <- joined[joined$geoid!=0,]
  
  if (dataset == "cutoff") {
    joined %$% table(is.na(nspuds.x),is.na(BOE))
  } else {
    joined %$% table(is.na(nspuds),is.na(BOE))
  }
  
  joined %$% table(is.na(everdrill),is.na(everprod))
  joined %$% table(everdrill,everprod)
  
  cnties <- joined %>% distinct(everdrill,everprod,geoid)
  
  cnties %$% table(everdrill,everprod)
  
  cnties %<>% mutate(
    category = case_when(everprod & everdrill ~ 'both',
                         everprod & !everdrill ~ 'prod',
                         !everprod & everdrill ~ 'spud',
                         !everprod & !everdrill ~ 'neither',
                         TRUE ~ 'ERROR')
  )
  
  SHP$GEOID %>% head
  cnties$geoid %>% head
  
  if (dataset == "all") {
    cnties_all <- cnties
  }
  
  if (dataset == "cutoff") {
    cnties_cutoff <- cnties
  }
  
 }
  


  # Remove counties from cnties_all not included in cnties_cutoff

  cutoff_counties <- as.vector(cnties_cutoff$geoid)
  cnties_new <- subset(cnties_all, cnties_all$geoid %in% cutoff_counties)
  
  

# 2 maps
  # 1. raw data current map
  # 2. subset data to counties in the union of the 5% cutoff datasets
  
for (dataset in c("all","cutoff")) { 
  
# Category Map
  
  png(paste0(dataset,'CategoryMap.png'),width=2000,height=1200)
  par(mar=c(5,4,4,2),adj=.5)
      
  # Import data
      
  setwd(.rt_data)
  SHP <- raster::shapefile('cb_2018_us_county_within_cd116_500k.shp')
  SHP2 <- raster::shapefile('cb_2018_us_state_20m.shp')
  if (dataset == "all") {
    cnties <- cnties_all
  }
  if (dataset == "cutoff") {
    cnties <- cnties_new
  }
      
      
  # Clean data
      
    # SHP
    SHP <- SHP[!SHP$STATEFP %in% c('02',15,60,66,69,72,78), ]
  
    SHP@data$GEOID <- paste0(SHP@data$STATEFP,SHP@data$COUNTYFP)
    SHP@data$GEOID <- as.numeric(as.character(SHP@data$GEOID))
    SHP@data$GEOID <- as.numeric(SHP@data$GEOID)
    SHP@data$GEOID <- str_pad(SHP@data$GEOID, width=5, side="left", pad="0")
        
    # SHP2
    SHP2 <- SHP2[!SHP2$NAME %in% c('Alaska','Hawaii'), ]
    SHP2 <- spTransform(SHP2,raster::crs(SHP))
      
    # cnties
    cnties$geoid <- str_pad(cnties$geoid, width=5, side="left", pad="0")
      
  
  # Join data
    
  SHP_cnties <- sp::merge(SHP, cnties, by.x = "GEOID", by.y = "geoid")
  spdf <- SHP_cnties
      
  
  # Plot data
      
  spdf$fillcolor <- NA
  spdf$fillcolor <- ifelse(spdf$category == 'both', '#636363',
                    ifelse(spdf$category == 'spud', '#bdbdbd',
                    ifelse(spdf$category == 'prod', '#f0f0f0','white')))
  spdf$fillcolor[is.na(spdf$fillcolor)] <- 'white'
      
  setwd(.rt_output)
      
  plot(spdf, col = spdf$fillcolor, lwd = 0.001, border=NA)
  plot(SHP2, border='black', lwd = 1, add=TRUE) 
  
  title(main='Spud and Prod Data Distribution.',cex.main = 3.5,line = 0,family = 'Times New Roman')
  legend(x = 'right',
         inset = c(-0.01,0.05),
         xjust = 0.05,
         yjust = 0.5,
         legend = c('Both','Spud','Prod'),
         title = 'Legend',
         col = c('#636363','#bdbdbd','#f0f0f0'),
         border = "black",
         pch = c(19,19,19),
         bty = "n",
         cex = 3.3,
         text.col = "black",
         horiz = F, xpd = NA)
  
  
  dev.off()
  
  
}

