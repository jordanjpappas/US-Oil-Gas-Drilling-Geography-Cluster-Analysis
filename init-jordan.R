# Jordan Pappas, Richard DiSalvo
# University of Rochester Medical Center, Princeton University
# jordan.pappas@rochester.edu





# Set directories

.rt_proj <- "/Users/Jordan/Box/ShaleGas/Proj/oldnewdrillingclassify/"

.rt_data <- paste0(.rt_proj,'data')
.rt_output <- paste0(.rt_proj,'output')
.rt_scratch <- paste0(.rt_proj,'scratch')

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
# library(mclust)
library(sp)
library(rgdal)
library(maptools)
library(raster)
library(rgeos)

