

#########################################################################

### initial script to ID cloud heavy scenes and mask cloudy areas

#########################################################################


library(RStoolbox)
library(raster)
library(plyr)
library(dplyr)
library(compositions)


#--------------------------------------------------------------------------

### Loop through and load

#--------------------------------------------------------------------------

setwd('E:/Modules/RS/Data/LS')
years <- c('/2017', '/2018')

for (i in 1:length(years)){
  
  ### loop through years of analysis
  
  wd1 <- substr(getwd(), 1, 22)
  wd <- paste0(wd1, years[i])
  setwd(wd)
  
  files <- list.files()
  files <- files[!files %in% files[contains('gz', vars = files)]] 
  
  for (j in 1:length(files)) {
    
    ### loop through directories containing individual Landsat scenes
    
    setwd(wd)
    setwd(paste0(getwd(), '/', files[j]))
    setwd(paste0(getwd(), '/', substr(files[j], 1, nchar(files[j]) - 4)))
    print(getwd())
    
    ### select cropped scenes

    wd2 <- getwd()
    setwd(paste0(getwd(), '/crop'))
    
    ### read in bands of scene

    #dat.files <- list.files(pattern = '.tif') ### keep code for Sentinel
    #dat.files <- dat.files[dat.files %in% dat.files[contains('band', vars = dat.files)]]
    
    files.qa      <- list.files(pattern = 'qa')
    files.qa      <- files.qa[!files.qa %in% files.qa[contains('xml', vars = files.qa)]] 
              
    files.dat     <- list.files(pattern = '.tif')
    files.dat     <- files.dat[!files.dat %in% files.dat[contains('qa', vars = files.dat)]] 
    files.dat     <- files.dat[!files.dat %in% files.dat[contains('aux', vars = files.dat)]] 
    
    LS.crop       <- stack(unlist(lapply(files.dat, raster)))
    
#-------------------------------------------------------------------------------------------------
    
    ### QA Layer 
    
#------------------------------------------------------------------------------------------------- 
    
    ### load qa
    
    qa1.crop                   <- raster(files.qa)
    qa1.crop[is.na(qa1.crop)]  <- 0
    qa1.crop.inclcirrus        <- qa1.crop

    ### process

    qa1.crop.vals    <- qa1.crop[, ]
    qa1.crop.bins    <- binary(qa1.crop.vals, mb = 16)
    
    qa1.crop.mask    <- substr(qa1.crop.bins, 14, 14) == '0' & substr(qa1.crop.bins, 12, 12) == '0' & substr(qa1.crop.bins, 2, 2) == '0' # & substr(qa1.crop.bins, 6, 6)  == '0' 
    qa1.crop.cirrus  <- substr(qa1.crop.bins, 14, 14) == '0' & substr(qa1.crop.bins, 2, 2) == '0' # & substr(qa1.crop.bins, 6, 6)  == '0' 
    
    values(qa1.crop) <- qa1.crop.mask
    plot(qa1.crop)
    
    values(qa1.crop.inclcirrus) <- qa1.crop.cirrus
    plot(qa1.crop.inclcirrus)
    
    
    ### Apply non-cirrus mask to data
    
    LS.crop          <- LS.crop * qa1.crop
    
######### *** Issue: do we include cirrus or not? With medium confidence? Ask for advice ***
    
        
    #qa1           <-  calc(qa1, function(x) {binary(x, mb = 16)})
    #qa1.cloud     <-  calc(qa1, function(x) {bit(x, 14) == 0 & bit(x, 15) == 1})
    #qa1.cirrus    <-  calc(qa1, function(x) {bit(x, 12) == 0 & bit(x, 13) == 1})
    #qa1.shadow    <-  calc(qa1, function(x) {bit(x, 6) == 0 & bit(x, 7) == 1})
    #qa1.water     <-  calc(qa1, function(x) {bit(x, 4) == 0 & bit(x, 5) == 1})
    
    #Bit 0 = 0 = not fill
    #Bit 1 = 0 = not a dropped frame
    #Bit 2 = 0 = not terrain occluded
    #Bit 3 = 0 = ignore
    #Bit 4-5 = water
    #Bit 6-7 = cloud shadow
    #Bit 8-9 = veg
    #Bit 10-11 = snow/ice
    #Bit 12-13 = cirrus cloud
    #Bit 14-15 = cloud
    
    #---------------------------------------------------------------------------------
    ### write out
    #---------------------------------------------------------------------------------
    
    
    setwd(wd2)
    
    dir.create(file.path(getwd(), 'QA_mask'), showWarnings = TRUE)
    setwd(file.path(getwd(), '/QA_mask'))  
    
    for (k in 1:nlayers(LS.crop)) {
      writeRaster(LS.crop[[k]], filename = paste0('Masked', names(LS.crop[[k]]), '.tif'))
    }
    
    writeRaster(qa1.crop, filename = paste0('QA_mask', as.character(substr(files[j], 11, 18)), '.tif'), overwrite = TRUE)
    writeRaster(qa1.crop.inclcirrus, filename = paste0('QA_mask_inclcirrus', as.character(substr(files[j], 11, 18)), '.tif'), overwrite = TRUE)
    
  }
}


############### Experimenting with Writing out and using stackMeta

#setwd('E:/Modules/RS/Data/LS/2017/LC082230692017011101T1-SC20181119144225.tar')
#writeRaster(dat, filename="multilayer.tif", options="INTERLEAVE=BAND", overwrite=TRUE)
#
#m <- readMeta(list.files(pattern = 'xml'))
#
#s <- stackMeta(m)
#
#
#for (k in 1:nlayers(dat)) {
#  
#  writeRaster(dat[[k]], filename = paste0('cloudfree', dat.files[k]))
#  
#}

###############




