


###################################

## applies mask to Sen2 images, converts to reflectances and writes out

###################################


library(raster)


system("subst x: E:/Modules/RS/Data/Sentinel")
setwd('x://') ## base file path - reduces filepath below 260 char limit

#----------------------------------------------------------------

# loop through

#----------------------------------------------------------------

years = c('2018')


for (i in 1:length(years)){
  
  ### loop through years of analysis
  setwd('x://') ## base file path - reduces filepath below 260 char limit
  wd1 <- substr(getwd(), 1, 51)
  wd <- paste0(wd1,'/', years[i])
  setwd(wd)
  
  files <- list.files()
  files <- files[!files %in% files[contains('gz', vars = files)]] 
  
  for (j in 17:length(files)) {
    
    ### acces cropped Sentinel dirs
    
    setwd(wd)
    setwd(paste0(getwd(), '/', files[j]))
    
    files2 <- list.files()
    setwd(paste0(getwd(), '/', files2[files2 %in% files2[contains('MSIL2A', vars = files2)]]))
    
    outpath <- getwd()
    setwd(paste0(getwd(), '/', 'crop'))

    print(getwd())
    
#------------------------------------------------------

### Load data

#-----------------------------------------------------
    

    ### read in Sentinel data

    my.files = list.files()
    my.files <- my.files[!my.files %in% my.files[contains('aux', vars = my.files)]] 
    my.files     <-  my.files[my.files %in% my.files[contains('B', vars = my.files)]] 
    Sen.20 <- stack(unlist(lapply(my.files, raster)))

    ### SCL

    SCL.file <- list.files(pattern = 'SCL')
    SCL      <- raster(SCL.file)

    ### Plot TCI for comparison

    TCI.file <- list.files(pattern = 'TCI')
    TCI      <- raster(TCI.file)
    #plot(TCI)


#---------------------------------------------------------------------

### Process data

#---------------------------------------------------------------------


    ### make mask

    Mask                    <- SCL == 4 | SCL == 5 | SCL == 6
    Mask.withcirrus         <- SCL == 4 | SCL == 5 | SCL == 6 | SCL == 10


    ### apply mask

    Sen.20                  <- (Sen.20 * Mask) / 10000

    
#---------------------------------------------------------------------------------------

# write out
    
#---------------------------------------------------------------------------------------
    
    
    setwd(outpath)

    dir.create(file.path(getwd(), 'masked'), showWarnings = TRUE)
    setwd(file.path(getwd(), '/masked'))  

    for (k in 1:nlayers(Sen.20)) {
  
      writeRaster(Sen.20[[k]], filename = paste0('Masked_', substr(my.files[k], 1, nchar(my.files[k]) - 4), '.tif'), overwrite = TRUE)
  
    }
    print(j)
  }
}











