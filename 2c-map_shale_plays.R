# Jordan Pappas, Richard DiSalvo
# University of Rochester Medical Center, Princeton University
# jordan.pappas@rochester.edu





# Play Plots

  # New Shale
  
    # Set directories
    
    setwd(.rt_data)
    SHP1 <- raster::shapefile('cb_2018_us_nation_5m.shp')
    setwd(.rt_data)
    SHP2 <- raster::shapefile('ShalePlays_US_EIA_Sep2019.shp')
    
    png('NewShaleMap.png',width=1600,height=800)
    par(mar=c(5,4,4,2))
    
    setwd(.rt_output)
    
    # Plot data
    
    plot(SHP2, border = 'black', lwd = .5)
    plot(SHP1, border = 'black', add=TRUE)
    
    show_ls = c('Marcellus', 'Utica', 'Haynesville-Bossier', 'Barnett', 'Eagle Ford', 'Spraberry', 'Wolfcamp', 'Bakken', 'Niobrara')
    SHP2$show <- 0
    SHP2$show <- ifelse(SHP2$Shale_play %in% show_ls, 1, 0)
    
    SHP2 <- SHP2[SHP2$show == 1, ]
    text(coordinates(SHP2)[,1], coordinates(SHP2)[,2], SHP2$Shale_play)
    
    dev.off()

  # Old Oil & Gas
  
    # Set directory
    
    setwd(.rt_data)
    SHP1 <- raster::shapefile('cb_2018_us_nation_5m.shp')
    setwd(.rt_data)
    SHP2 <- raster::shapefile('Oil_NG_Fields.shp')
    
    png('OldO&GMap.png',width=1600,height=800)
    par(mar=c(1,1,1,1))
    
    # Clean data
    
    SHP2 <- spTransform(SHP2,crs(SHP1))
    
    SHP2 <- SHP2[SHP2$NAME %in% c('SAN JOAQUIN BASIN','PERMIAN BASIN','SAN JUAN BASIN','WIND RIVER BASIN','EAST TEXAS BASIN','DENVER BASIN','Greater Green River Basin','UINTA-PICEANCE','UINTA BASIN'),]
    SHP2 <- SHP2[SHP2$FID %in% c(14,19,23,26,122,144,165,191),]
    
    SHP2_centroid <- coordinates(SHP2)
    
    setwd(.rt_output)
    
    # Plot data
    
    plot(SHP2, border = 'black', lwd = .5)
    plot(SHP1, border = 'black', add=TRUE)
    
    points(SHP2_centroid, pch = 8, col = "black", cex = 1.5)
    
    text(coordinates(SHP2)[,1], coordinates(SHP2)[,2], SHP2$NAME, cex = 3)
    
    dev.off()

