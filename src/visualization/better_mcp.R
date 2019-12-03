# This is an efficient way to calculate multiple MCPs from a dataset.
# It assumes the dataset is from a single individual,
# but it could easily be adapted for multiple individuals.
# It outputs separate .shp files for each percentage
# with the naming format 'SiteName/ID_yyyy-mm-dd_yyyy-mm-dd_%%.shp'

rm(list = ls())   # Clear the workspace.
gc()              # Perform a garbage collection.

# Set the working directory.
setwd('')

# Load some libraries.
library(sp)
library(adehabitatHR)
library(rgdal)
library(purrr)

# Import clean data.
df <- 
  read.csv('data.csv',
           stringsAsFactors=FALSE)

# Changes names, etc. as needed. 
# This simplifies the file naming process later
site <- 'SiteName'                # Should point to directory.
date <- 'yyyy-mm-dd_yyyy-mm-dd'   # Part of file name.
id <- 'ID'                        # Part of file name.

# Transform into a spatial data frame.
# Specify which columns contain lat/lon data.
coordinates(df) <- df[, c('lon', 'lat')]
proj4string(df) = CRS("+init=epsg:4326")

# Calculate polygons and save as shapefiles.
# Change percent values as needed.
# The indexing points to the id column, which is all the same in this case.
# However, adehabitat requires it to be specified.
purrr::walk(c(100, 90, 50), function(x){
  writeOGR(obj=mcp(df[, 2], percent = x),
           dsn=site,
           layer=paste(id, '_', date, '_', as.character(x), sep=''), 
           driver='ESRI Shapefile', overwrite_layer=TRUE)
})