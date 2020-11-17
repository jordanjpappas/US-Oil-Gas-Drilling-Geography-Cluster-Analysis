# Richard DiSalvo, Jordan Pappas
# Princeton University, University of Rochester Medical Center
# jordan.pappas@rochester.edu





# Load data

library(flextable)
library(WordR)
library(officer)

setwd(.rt_data)
x <- read_csv('summary_stats_table.csv')
x <- rbind(names(x),x)

names(x) <- paste0('C',1:ncol(x))
x[1,1] <- ''


out <- dismisc::flextable_convert_standard(x)
out %<>% flextable::merge_at(i=2,j=1:3) %>% align(i = 2, j = 1, align = 'left') %>% bold(i = 2, j = 1)
out %<>% flextable::merge_at(i=8,j=1:3) %>% align(i = 8, j = 1, align = 'left') %>% bold(i = 8, j = 1)
out %<>%  bold(i = 14, j = 1)
out %<>% flextable::border(i = 14, j = 1:3, border.top =fp_border(width=2))
out %<>% flextable::border(i = 2, j = 1:3, border.top =fp_border(width=2))
ft_summstats <- out
ft_summstats %<>% width(j = 1, width = 1.5)

# cluster summaries ---------
setwd(.rt_scratch)
x <- readRDS('stateclustersummary.rds')
x$State %<>% str_to_title()
x <- rbind(c('State','Number of Counties','% Clust 1','% Clust 2','% Clust 1','% Clust 2','% Clust 3'),x)
x <- rbind(c('','','Two Clusters','','Three Clusters','',''),x)
names(x) <- paste0('C',1:ncol(x))
out <- dismisc::flextable_convert_standard(x)
out %<>% flextable::merge_at(i=1,j=3:4) %>% align(i=1,j=3,align='center')
out %<>% flextable::merge_at(i=1,j=5:7) %>% align(i=1,j=5,align='center')
out %<>% flextable::border(i = NULL, j = 3, border.left = fp_border())
out %<>% flextable::border(i = NULL, j = 5, border.left = fp_border())
out %<>% width(j=1,width=1.25)
out %<>% width(j=3:7,width=0.9)
ft_states <- out


setwd(.rt_scratch)
x <- readRDS('playclustersummary.rds')
x$Shale_play %<>% as.character()
# x$ %<>% str_to_title()
x <- rbind(c('Shale Play','Number of County-Play Combinations','% Clust 1','% Clust 2','% Clust 1','% Clust 2','% Clust 3'),x)
x <- rbind(c('','','Two Clusters','','Three Clusters','',''),x)
names(x) <- paste0('C',1:ncol(x))
out <- dismisc::flextable_convert_standard(x)
out %<>% flextable::merge_at(i=1,j=3:4) %>% align(i=1,j=3,align='center')
out %<>% flextable::merge_at(i=1,j=5:7) %>% align(i=1,j=5,align='center')
out %<>% flextable::border(i = NULL, j = 3, border.left = fp_border())
out %<>% flextable::border(i = NULL, j = 5, border.left = fp_border())
out %<>% width(j=1,width=1.25)
out %<>% width(j=3:7,width=0.9)
ft_plays <- out


  
#change working directory
setwd(.rt_proj)
setwd("paper")

#compile doc 
FT <- list(summstats = ft_summstats,
           states = ft_states,
           plays = ft_plays
)
touse <- "v20-oldnewdrillingclassify.docx"
WordR::body_add_flextables(touse, "oldnewdrillingclassify-compiled.docx", FT)







