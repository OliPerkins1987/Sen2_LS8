

#########################################################################

### This is the georeferencing and imaging matching script

#########################################################################


library(RStoolbox)
library(raster)
library(plyr)
library(dplyr)
library(rgdal)

### Load index

setwd('E:/Modules/RS/Data/Dates')
index <- read.csv('!index_refreshed.csv')

### Load filepaths

#-----------------------------------------------------------------------------------------------------------

### Load landsat

#-----------------------------------------------------------------------------------------------------------


setwd('E:/Modules/RS/Data/LS')
years <- c('/2017', '/2018')

for (i in 1:length(years)){
  
  ### loop through years of analysis
  
  setwd('E:/Modules/RS/Data/LS')
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

#-------------------------------------------------------------------------------------
    
    ### load Landsat
    
#-------------------------------------------------------------------------------------
    
    ### Masked scenes
    
    wd2 <- getwd()
    setwd(paste0(getwd(), '/QA_Mask'))
    
    LS.files <- list.files(pattern = 'Maskedlayer')
    LS.files <- LS.files[!LS.files %in% LS.files[contains('aux', vars = LS.files)]]
    LS.dat   <- stack(unlist(lapply(LS.files, raster)))
    
    
#-------------------------------------------------------------------------------------
    
### load Sentinel
    
#-------------------------------------------------------------------------------------
    
    ### Load Sentinel
    
    Nearest.Sen <- index$Nearest.Sentinel[i]
    
    setwd(as.character(index$Filepath.Sen[i]))
    Sen.paths <- list.files(pattern = 'S2A_MSIL2A')
    setwd(paste0(getwd(), '/', Sen.paths[1]))
    
    setwd(paste0(getwd(), '/resample'))
    Sen.files <- list.files()
    Sen.files <- Sen.files[!Sen.files %in% Sen.files[contains('aux', vars = Sen.files)]]
    Sen.files <- c(Sen.files[1], Sen.files[2], Sen.files[3], Sen.files[6], Sen.files[7], Sen.files[8], Sen.files[8])
    
    Sen.dat   <- stack(unlist(lapply(Sen.files, raster)))

    
#-----------------------------------------------------------------------------------------------------------
    
### Automatic coregistration
    
#-----------------------------------------------------------------------------------------------------------
    
    
    extent(LS.dat) <- crop(LS.dat, y = extent(Sen.dat))
    LS.coregister  <- coregisterImages(LS.dat, Sen.dat, verbose = TRUE)
    
    #for (k in 1:nlayers(LS.coregister)) {
    #
    #plot(LS.coregister[[k]]) 
    #plot(LS.dat[[k]])
    #
    #}

    
#--------------------------------------------------------------------------------------------------------
    
    ### write out
    
#--------------------------------------------------------------------------------------------------------
    
    setwd(wd2)
    
    dir.create(file.path(getwd(), 'co_register'), showWarnings = TRUE)
    setwd(file.path(getwd(), '/co_register'))  
    
    
    for (k in 1:nlayers(LS.coregister)) {
      
      writeRaster(LS.coregister[[k]], filename = paste0('coreg_', LS.files[k]), overwrite = TRUE)
      
    }
    
    
  }
}


