#Aggregate environmental variables to section corners
#Started on 6/24/2021

#Load libraries -----------

library(tidyverse)
library(tidylog)
library(magrittr)
library(sf)
library(raster)
library(spatialEco)
library(exactextractr)

setwd("D:/Dropbox/Forest Composition/composition/Maps/shapefiles/INILProject")

#Section corners ----------

corner <- st_read('Hoosier_National_Forest_IN_PLS_v2.0_Corners.shp') %>%  #TODO: change for all section corners
  dplyr::select(cornerid, typecorner) %>% #Too many fields, grabbing a couple for simplicity
  st_transform(., crs = 3175) %>% #change to Albers Great Lake
  st_buffer(., 10) #buffer to 10m 

#TODO: I am doing this by creating a small buffer around each point. We can change that buffer size
#if it is preferable. However, the zonal.stats function that I'm using to extract values requires a
#polyogon, not a point. If we want to extract point data we need to find a new function or make
#an extremely small polygon by changing the buffer size to 0.0001 or something.

  
#Slope --------------------

slope <- raster('geomorphon/DEM10m/Slope.tif') 

cornerSlope <- zonal.stats(corner, slope, stats = 'mean') %>% 
  cbind(corner,.)

#Aspect -------------------

aspect <- raster('geomorphon/DEM10m/Aspect.tif')

cornerSlopeAspect <- zonal.stats(corner, aspect, stats = 'mean') %>% 
  cbind(cornerSlope, .)

#Soils --------------------

#I merged the two state's soils data in QGIS and rewrote as a tif in QGIS.
#This script reads in those merged files.

#Load soil rasters and calculate stats
CAC <- raster('Soils/CAC.tif') %>% 
  zonal.stats(corner,., stats = 'mean')

CEC <- raster('Soils/CEC.tif') %>% 
  zonal.stats(corner,., stats = 'mean')

CLA <- raster('Soils/CLA.tif') %>% 
  zonal.stats(corner,., stats = 'mean')

KSA <- raster('Soils/KSA.tif') %>% 
  zonal.stats(corner,., stats = 'mean')

SAN <- raster('Soils/SAN.tif') %>% 
  zonal.stats(corner,., stats = 'mean')

SIL <- raster('Soils/SIL.tif') %>% 
  zonal.stats(corner,., stats = 'mean')

WAT <- raster('Soils/WAT.tif') %>% 
  zonal.stats(corner,., stats = 'mean')

#Join soil data back to main df

cornerSlopeAspectSoil <- cbind(cornerSlopeAspect, CAC, CEC, CLA, KSA, SAN, SIL, WAT)

#Landform ----------------- 
#TODO: need to create landform layer in QGIS

#Climate ------------------
#TODO: need to create prism climate data

#Write out ----------------

