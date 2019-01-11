


###################################

## applies mask to Sen2 images, converts to reflectances and writes out

###################################


library(raster)

setwd('E:/Modules/RS/Data/LS/2016/LC082230692016100701T1-SC20181126075757.tar/LC082230692016100701T1-SC20181126075757/QA_mask')
LS.example <- raster(list.files(pattern = '.tif')[1])

###################################################################




system("subst x: E:/Modules/RS/Data/Sentinel")
setwd('x://') ## base file path - reduces filepath below 260 char limit

#----------------------------------------------------------------

# loop through

#----------------------------------------------------------------

years = c('2017', '2018')


for (i in 1:length(years)){
  
  ### loop through years of analysis
  setwd('x://') ## base file path - reduces filepath below 260 char limit
    wd1 <- substr(getwd(), 1, 51)
  wd <- paste0(wd1,'/', years[i])
  setwd(wd)
  
  files <- list.files()
  files <- files[!files %in% files[contains('gz', vars = files)]] 
  
  for (j in 1:length(files)) {
    
    ### access cropped Sentinel dirs
    
    setwd(wd)
    setwd(paste0(getwd(), '/', files[j]))
    
    files2 <- list.files()
    setwd(paste0(getwd(), '/', files2[files2 %in% files2[contains('MSIL2A', vars = files2)]]))
    
    outpath <- getwd()
    setwd(paste0(getwd(), '/masked'))

    print(getwd())
    
#------------------------------------------------------

### Load data

#-----------------------------------------------------
    

    ### read in Sentinel data

    my.files = list.files()
    my.files     <-  my.files[my.files %in% my.files[contains('B', vars = my.files)]] 
    my.files     <-  my.files[!my.files %in% my.files[contains('aux', vars = my.files)]] 
    Sen.20 <- stack(unlist(lapply(my.files, raster)))


#---------------------------------------------------------------------

### Process data

#---------------------------------------------------------------------


    Sen.30m        <- resample(Sen.20, LS.example)

    
#---------------------------------------------------------------------------------------

# write out
    
#---------------------------------------------------------------------------------------
    
    
    setwd(outpath)

    dir.create(file.path(getwd(), 'resample'), showWarnings = TRUE)
    setwd(file.path(getwd(), '/resample'))  

    for (k in 1:nlayers(Sen.30m)) {
  
      writeRaster(Sen.30m[[k]], filename = paste0('Resample_', substr(my.files[k], 1, nchar(my.files[k]) - 5), '.tif'), overwrite = TRUE)
  
    }
    print(j)
  }
  print(years[i])
}











