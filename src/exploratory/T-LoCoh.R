# Select just one site to work with.
ska <- df %>% filter(site == 'SKA')

# To make a lxy object, we need datetime and coordinates.

# Do the datetime thing.
datetime <- ymd_hms(ska$datetime, tz='America/Vancouver')

# Do the spatial thing. This is a bit different than usual.
ska.sf <- SpatialPoints(ska[ , c('lon', 'lat')],
  proj4string=CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')) %>%
  spTransform(CRS('+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs'))

ska.coords <- coordinates(ska.sf)
colnames(ska.coords) <- c('x', 'y')

# Make a lxy object.
ska.lxy <- xyt.lxy(xy=ska.coords, dt=datetime, id='HAR05',
                proj4string=CRS('+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs'))

# Look at some stuff.
summary(ska.lxy)
plot(ska.lxy)
hist(ska.lxy)

# Look for unusual bursts.
lxy.plot.freq(ska.lxy, cp=T)
