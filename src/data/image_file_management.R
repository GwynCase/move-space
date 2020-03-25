# This is a nice workflow for handling the many many images from nest cams.

# Load up some libraries.
library('tidyverse')
library('exiftoolr')
library('lubridate')
library('purrr')

# The first time you run exiiftoolr you need to to install exiftools.
# This only needs to happen once.
# install_exiftool()

# Fill in these three things:
# Where are the pictures now?
path.in <- 'D:/RECONYX/Turbid/102RECNX_Turbid/'

# What site is it?
site <- 'TCR3'

# Where are the pictures going?
# END WITH A FORWARD SLASH
path.out <- 'E:/'

# Now just hit run and the rest will take care of itself.
# IT WILL TAKE A WHILE. GO GET A COFFEE AND BE PATIENT.
###
###
###

# Make a new directory for the files.
site.dir <- paste0(path.out, site)
dir.create(site.dir)

# Get a list of the photos.
photo.list <- list.files(path.in, full.names=TRUE) %>%
  exif_read(tags=c('filename', 'CreateDate', 'SerialNumber'))

# Create a data frame.
photo.df <- photo.list %>%
  dplyr::select(filename=FileName, datetime=CreateDate,
                serial=SerialNumber) %>%
  mutate(site=site, datetime=ymd_hms(datetime)) %>%
  add_column(interest='', live.chicks='', class='', family='',
             genus='', species='', common='', size='', comments='')

# Save a csv with all the photos.
write.csv(photo.df,
          file=paste0(site.dir, '/', site, '_photos_all.csv'),
          row.names=FALSE)

# Add a week column.
photo.df <- photo.df %>%
  mutate(week=week(datetime), week=paste0('week_', week))

# Nest the data frame.
photo.nest <- photo.df %>% group_nest(week)

# Split the data frame by week and save as separate csvs.
walk2(photo.nest$week, photo.nest$data, function(week, data) {
  path <-  paste0(site.dir, '/', week, '/', site, '_photos_', week, '.csv')
  dir.create(dirname(path), recursive=TRUE, showWarning=FALSE)
  write.csv(data, file=path, row.names=FALSE)
})

# Copy the photos into the appropriate directories.
walk2(photo.df$week, photo.df$filename, function(week, filename) {
  target <-  paste0(site.dir, '/', week, '/', filename)
  source <- file.path(path.in, filename)
  file.copy(source, target)
})
