# Richard DiSalvo, Jordan Pappas
# Princeton University, University of Rochester Medical Center
# jordan.pappas@rochester.edu





# Load data

setwd('/Users/Jordan/Box/ShaleGas/Drillinginfo/Nationwide/National_All_Wells/Datasets/')

wells <- '1990_2020may_cleaned.csv' %>%  readr::read_csv(.,col_types = cols(.default='c'))



# Clean data

wells %<>% filter(
  productiontype %in% c('OIL & GAS','GAS','OIL','GAS OR COALBED','CBM')
)

wells %<>% select(STATE,COUNTY,spud_year,drilltype,productiontype,spud_year)

setwd('D:/Box Sync/ShaleGas/Proj/oldnewdrillingclassify/data')
wells %>% write_csv('wellsextract2020_07_08.csv')

wells %>% group_by(STATE,COUNTY,spud_year,drilltype) %>% summarize(
  nspuds = n()
) -> tmp

tmp %<>% dcast(STATE + COUNTY + spud_year ~ drilltype)
tmp[is.na(tmp)] <- 0
tmp %<>% mutate(
  nspuds = D + H + V + U,
  nspudsweighted2pt7 = (D + H)*(2.7) + V
)
tmp %<>% select(-D,-H,-V)
tmp %<>% select(-U)

setwd('D:/Box Sync/ShaleGas/Proj/oldnewdrillingclassify/data')
tmp %>% saveRDS('nationalwellsbycountyyear.rds')

