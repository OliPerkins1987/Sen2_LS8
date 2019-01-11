
#########################################################################

### Correct to atmospheric reflectances and remove values < 0

#########################################################################





library(RStoolbox)
library(raster)
library(plyr)
library(dplyr)
library(rgdal)



#--------------------------------------------------------------------------

### Create cloud masks - loop through and load

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
    
    ### read in bands of scene
    
    #dat.files <- list.files(pattern = '.tif') ### keep code for Sentinel
    #dat.files <- dat.files[dat.files %in% dat.files[contains('band', vars = dat.files)]]
    
    xml_meta      <- readMeta(list.files(pattern = 'xml'))
    dat           <- stackMeta(xml_meta)
    
    ### Date
    
    dat.Date <- substr(files[j], 11, 18) ## extract date
    dat.Date <- as.Date(dat.Date, format = '%Y%m%d') ## format date
    
    
    
    #-------------------------------------------------------------------------------------------------
    
    ### Calculate Reflectances and set neg vals to 0 *** set vals > 1 to 1 ***
    
    #------------------------------------------------------------------------------------------------- 
    
    ###calc
    
    #n <- names(dat)
    
      for (k in 1:nlayers(dat)) {
    
        dat[[k]] <- dat[[k]] * 1e-04
    
      }
    
      for (k in 1:nlayers(dat)) {
        
        dat[[k]][dat[[k]] < 0] <- 0
    
      }
    
    #names(dat) <- n

    #-------------------------------------------------------------------------------------------------
    
    ### Plot and write out reflectance rasters
    
    #------------------------------------------------------------------------------------------------- 
    
    plot(dat[[3]])
    
    reflectance.files <- list.files(pattern = 'tif')
    reflectance.files <- reflectance.files[!reflectance.files %in% reflectance.files[contains('qa', vars = reflectance.files)] & !reflectance.files %in% reflectance.files[contains('aerosol', vars = reflectance.files)]]       
    
    dir.create(file.path(getwd(), 'reflectance'), showWarnings = TRUE)
    setwd(file.path(getwd(), '/reflectance'))  
    
    for (k in 1: nlayers(dat)) {
      
      writeRaster(dat[[k]], filename = paste0('Reflectance', reflectance.files[k]), overwrite = TRUE)
      
    }
    
  }
}

