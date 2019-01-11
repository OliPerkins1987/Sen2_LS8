

#########################################################################

### This script crops landsat images to Sentinel 2 CRS @ chosen extent

#########################################################################


library(RStoolbox)
library(raster)
library(plyr)
library(dplyr)
library(rgdal)


### get CRS of Sentinel images

setwd('E:/Modules/RS/Data/Sentinel/2016/S2A_MSIL1C_20161013T134212_N0204_R124_T22LEL_20161013T134206/S2A_MSIL2A_20161013T134212_N0204_R124_T22LEL_20161013T134206.SAFE/GRANULE/L2A_T22LEL_A006842_20161013T134206/IMG_DATA/R20m')

list.sen       <- list.files(pattern = '*.jp2')
dat.sen        <- raster(list.sen[3])
c.sen <- crs(dat.sen)

### set study extents

e.study       <- extent(c(537625, 610000, 8500000, 8600000))
e.study.warp  <-  extent(c(537520, 609880, -1500100, -1399900))

###

setwd('E:/Modules/RS/Data/LS')
years <- c('/2016', '/2017', '/2018')

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
    
    LS.files <- list.files(pattern = '.tif')
    LS.files <- LS.files[-c(2:3)]
    
    dat.LS <- lapply(LS.files, raster)

#-----------------------------------------------------------------------------------------------------------

### Warp & crop Landsat

#-----------------------------------------------------------------------------------------------------------

    dat.LS.crop   <- lapply(dat.LS, crop, y = e.study.warp)
    dat.LS.warp   <- lapply(dat.LS.crop, projectRaster, crs = c.sen)
    dat.LS.crop   <- lapply(dat.LS.warp, crop, y = e.study)



#-----------------------------------------------------------------------------------------------------------

### Write out

#-----------------------------------------------------------------------------------------------------------


    dir.create(file.path(getwd(), 'crop'), showWarnings = TRUE)
    setwd(file.path(getwd(), '/crop'))  

      for (k in 1: nlayers(stack(unlist(dat.LS.crop)))) {
  
      writeRaster(dat.LS.crop[[k]], filename = paste0('crop_', LS.files[k]), overwrite = TRUE)
  
    }

  }
  
}



