# Sen2_LS8
Code to batch-process Sentinel-2 &amp; Landsat 8 scenes to create a composite timeseries

Code should be run in integer order (IE Sentinel 1-3 before Landsat 4, co-register images).

This code assumes two key things:

1) file structure of scenes. 

Should be - core directory / instrument / year / 

Further sub directories should be those created by the sen2cor toolbox when processing Sentinel2 scenes, 
and using 7-zip with default settings to process the Landsat .tar files

2) Uses a CSV index of all scenes to temporally match landsat scenes to closest Sen-2 scene for co-registration. 
This just needs a list of all scenes you are using by instrument by year, and their relevant capture date.
I have consistently found pixels to shift -1,-1 during this process - but this may be CRS dependent. 

---

The code writes out extensively, performing most operations per scene rather than reading in many scenes and vectorising. 

It can therefore be run with limited RAM (8Gig) with a compete Sentinel-2 scene size as the study area. 




