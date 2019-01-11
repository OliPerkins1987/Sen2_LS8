

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


system("subst x: E:/Modules/RS/Data/Sentinel")
setwd('x://') ## base file path - reduces filepath below 260 char limit
years = c('2016', '2017', '2018')


for (i in 1:length(years)){
  
  ### loop through years of analysis
  setwd('x://') ## base file path - reduces filepath below 260 char limit
  wd1 <- substr(getwd(), 1, 51)
  wd <- paste0(wd1,'/', years[i])
  setwd(wd)
  
  files <- list.files()
  files <- files[!files %in% files[contains('gz', vars = files)]] 
  
  for (j in 17:length(files)) {
    
    ### loop through directories containing individual Landsat scenes
    
    setwd(wd)
    setwd(paste0(getwd(), '/', files[j]))
    
    files2 <- list.files()
    setwd(paste0(getwd(), '/', files2[files2 %in% files2[contains('MSIL2A', vars = files2)]]))
    
    outpath <- getwd()
    setwd(paste0(getwd(), '/', 'GRANULE'))
    
    files3 <- list.files()
    setwd(paste0(getwd(), '/', files3[1], '/', 'IMG_DATA', '/', 'R20m'))
    
    ### LOAD FILES
    
    Sentinel.files <- list.files(pattern = '.jp2')
    Sentinel.files <- Sentinel.files[!Sentinel.files %in% Sentinel.files[contains('aux', vars = Sentinel.files)]]
    dat.Sen        <- stack(unlist(lapply(Sentinel.files, raster)))
      
    
#-----------------------------------------------------------------------------
    
    ### Crop and write out
    
#-----------------------------------------------------------------------------
    
    
    ### crop
    
    dat.Sen.crop <- crop(dat.Sen, y = e.study)
    
    
    ### write out
    
    setwd(outpath)
    
    dir.create(file.path(getwd(), 'crop'), showWarnings = TRUE)
    setwd(file.path(getwd(), '/crop'))  
    
    for (k in 1:nlayers(dat.Sen.crop)) {
      
      writeRaster(dat.Sen.crop[[k]], filename = paste0('crop_', substr(Sentinel.files[k], 1, nchar(Sentinel.files[k]) - 3), '.tif'), overwrite = TRUE)
      
    }
    print(j)
  }
}






### testing

test.files <- list.files(pattern = '.tif')
test <- stack(unlist(lapply(test.files, raster)))









