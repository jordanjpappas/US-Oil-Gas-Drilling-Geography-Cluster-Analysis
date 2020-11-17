# Richard DiSalvo, Jordan Pappas
# Princeton University, University of Rochester Medical Center
# jordan.pappas@rochester.edu



# compare unweighted and weighted clustering of counties in a few ways

setwd(.rt_output)

unwtd2clust <- readRDS('unweighted2fepoisson_clusters.rds')
wtd2clust <- readRDS('weighted2fepoisson_clusters.rds')

unwtd3clust <- readRDS('unweighted3fepoisson_clusters.rds')
wtd3clust <- readRDS('weighted3fepoisson_clusters.rds')


twoclust <- full_join(unwtd2clust,wtd2clust,by=c('STATE','COUNTY'))

twoclust %$% table(clust.x,clust.y)
twoclust %$% cor(clust.x,clust.y,method='pearson')
twoclust %$% cor(clust.x,clust.y,method='spearman')

threeclust <- full_join(unwtd3clust,wtd3clust,by=c('STATE','COUNTY'))
threeclust %$% table(clust.x,clust.y)
threeclust %$% cor(clust.x,clust.y,method='pearson')
threeclust %$% cor(clust.x,clust.y,method='spearman')


