rm(list = ls())   # Clear the workspace.
gc()            # Perform a garbage collection.

setwd('C:/Users/Gwyn/sfuvault')

# Load some libraries.
library('dplyr')
library('ggplot2')
library('sf')
library('ggspatial')
library('extrafont')

# Load the data.
df <- read.csv('Data/Telemetry/telem_all.csv', header=TRUE, 
               stringsAsFactors=FALSE)

# Select only the data you want.
ska <- filter(df, nest == 'SKA2019')

# Convert to spatial format.
sp.ska <- st_as_sf(ska, coords=c('lon', 'lat'), crs=4326, na.fail=FALSE)

# Add a point for the nest.
#n.ska <- st_as_sf(ska, coords=c('-123.84', '49.58'), crs=4326, na.fail=FALSE)

# Define map boundaries based on data spatial extent.
box <- st_bbox(sp.ska)

xlim <- c(box$xmin - 0.05, box$xmax + 0.05)
ylim <- c(box$ymin - 0.01, box$ymax + 0.01)

# Set the ggplot theme to something soothing and beautiful.
theme_set(theme_bw())

# Make a very, very simply map.
ggplot() +
  geom_sf(data=sp.ska) +
  annotate('point', x=-123.84, y=49.58, colour='red')

# Load base data.
ocean <- read_sf(dsn='NOGOmap/BaseData/canvec_land_clips', layer='ocean_clip')

# Make a map.
blank.ska <- ggplot() +
  geom_sf(data=ocean, fill='lightgrey') +
  #geom_sf(data=sp.ska) +
  #annotate('point', x=-123.84, y=49.58, colour='red') +
  # Removes x and y axis labels (i.e. "lat" and "long").
  theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
    axis.text = element_blank(), axis.ticks = element_blank(),
  # Workaround for a known bug that prevents removal of lat/lon grid.
    panel.grid.major = element_line(color='transparent'), 
    text=element_text(family = 'Lato')) +
  # Places scale bar + arrow in bottom left corner ('bl').
  annotation_scale(location = 'bl', width_hint = 0.5) +
  annotation_north_arrow(location = 'bl', which_north = 'true', 
    pad_x = unit(0.75, 'in'), pad_y = unit(0.5, 'in'),
    style = north_arrow_minimal()) +
  coord_sf(xlim=xlim, ylim=ylim, expand=FALSE)

ggsave('code/prints/ska_blank.png')

blank.ska
