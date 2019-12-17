rm(list = ls())   # Clear the workspace.
gc()            # Perform a garbage collection.

library('dplyr')
library('ggspatial')

# Filter data.
ska <- df %>%
  filter(site == 'SKA') %>%
  drop_na('lat')

# Make a 90% MCP for comparison.
mcp.90 <- SpatialPoints(ska[, c('lon', 'lat')], proj4string=CRS("+init=epsg:4326")) %>%
  mcp(percent=90)

# Plot the MCP.
ggplot() +
  geom_sf(data=st_as_sf(mcp.90)) +
  #theme_minimal() +
  theme(panel.grid.major=element_line(color='transparent'),
        axis.text=element_blank(),
        axis.ticks=element_blank(),
        panel.background=element_rect(fill='transparent')) +
  annotation_scale(style='ticks', location='bl', width_hint=0.4)

# Make sf object.
sf.ska <- st_as_sf(ska, coords=c('lon', 'lat'))
sf.ska <- st_set_crs(sf.ska, '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')

# Transform to UTM so area makes sense.
sf.ska <- st_transform(sf.ska, "+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs")

# Look at area.
mcp.ska <- sf.ska %>% as_Spatial() %>%
  mcp.area(percent=seq(20, 100, by=10),
           unin='m', unout='ha', plotit=FALSE) %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  rename(area=a)

ggplot(mcp.ska, aes(percent, area)) +
  geom_point() +
  geom_path() +
  theme_minimal() +
  theme(panel.grid=element_line(color='white')) +
  labs(x='Percent of location points', y='Home range area (ha)', title='Skaiakos')

# OK, so if I reduce my dataframe to id and coords, then mcp() works fine.
mcp.s <- sf.ska %>%
  dplyr::select(id, geometry) %>%
  as_Spatial()

mcp(mcp.s, percent = 100)

# BUT I need to separate seasons, so I guess I'd better do that first.

winter2 <- interval(ymd(20190101), ymd(20190414))
incubation <- interval(ymd(20190415), ymd(20190510))
nestling <- interval(ymd(20190511), ymd(20190710))
fledgling <- interval(ymd(20190711), ymd(20190901))
winter1 <- interval(ymd(20190902), ymd(20191231))

sf.ska.per <- sf.ska %>%
  mutate(yrls=ymd(paste(2019, month(datetime), day(datetime))),
         period=case_when(
           yrls %within% incubation ~ 'incubation',
           yrls %within% nestling ~ 'nestling',
           yrls %within% fledgling ~ 'fledgling',
           yrls %within% winter1 ~ 'winter',
           yrls %within% winter2 ~ 'winter'
         )
  ) %>%
  dplyr::select(geometry, period) %>%
  as_Spatial()

mcp.by.period <- sf.ska.per %>%
  mcp.area(percent=seq(20, 100, by=10),
           unin='m', unout='ha', plotit=FALSE) %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name)

mcp.by.period <- pivot_longer(mcp.by.period,
  cols=c('fledgling', 'nestling', 'winter'), names_to='period')

# And plot!

ggplot(mcp.by.period, aes(percent, value, color=period)) +
  geom_point() +
  geom_path() +
  theme_classic() +
  theme(panel.grid=element_line(color='white')) +
  labs(x='Percent of location points', y='Home range area (ha)', title='Skaiakos')

# Make a move object
ska$datetime <- ymd_hms(ska$datetime, tz='America/Vancouver')

move.ska <- move(x=ska$lon, y=ska$lat, time=ska$datetime, proj=CRS("+proj=longlat"))

hr <- hrBootstrap(x=move.ska, rep=25, unin='km', unout='km2', plot=TRUE)
