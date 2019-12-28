rm(list = ls())   # Clear the workspace.
gc()            # Perform a garbage collection.

# Define period of interest
nestling <- interval(ymd(20190511), ymd(20190710))

# Filter desired period, tags.
sf.df <- sf.df %>%
  mutate(yrls=ymd(paste(2019, month(datetime), day(datetime)))) %>%
  filter(datetime %within% nestling) %>%
  filter(id %in% c('HAR10', 'HAR09', 'HAR04', 'HAR05'))

sf.ska <- sf.df %>%
  mutate(yrls=ymd(paste(2019, month(datetime), day(datetime)))) %>%
  filter(datetime %within% nestling) %>%
  filter(id == 'HAR05')

# Make the kud.
kud <- sf.df %>%
  dplyr::select(id, geometry) %>%
  as_Spatial() %>%
  kernelUD(extent=0.25, grid=100)

image(kud)

v.all <- getverticeshr(kud)

plot(v.all)

# Let's try with just SKA

kud.ska <- sf.ska %>%
  dplyr::select(id, geometry) %>%
  as_Spatial() %>%
  kernelUD(extent=0.25, grid=100)

image(kud.ska)

v.ska <- getverticeshr(kud.ska, percent=75)

plot(v.ska)

# So that makes it visible, but what is the area?
as.data.frame(v.all)


# Let's come back to that later.
# But let's look at contours.
kud.ska.df <- raster(as(kud.ska$HAR05,"SpatialPixelsDataFrame")) %>%
  rasterToPoints() %>%
  as.data.frame()

ggplot(kud.ska.df, aes(x, y, z=ud)) +
  geom_contour(color='black', bins=10) +
  theme_void()

# OK, let's go back to calculating area.
kud.95 <- kernel.area(kud, percent=95, unin='m', unout='ha') %>%
  as.data.frame %>%
  `rownames<-`('95% KDEs (ha)')

kable(kud.95, format='pandoc', digits=2, caption='2019 nestling season')