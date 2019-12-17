rm(list = ls())   # Clear the workspace.
gc()            # Perform a garbage collection.

# Get subset of data we actually want.
df$datetime <- ymd_hms(df$datetime, tz='America/Vancouver')

df <- df %>%
  drop_na('lat') %>%
  mutate(yrls=ymd(paste(2019, month(datetime), day(datetime))),
         period=case_when(
           yrls %within% incubation ~ 'incubation',
           yrls %within% nestling ~ 'nestling',
           yrls %within% fledgling ~ 'fledgling',
           yrls %within% winter1 ~ 'winter',
           yrls %within% winter2 ~ 'winter'
         )
  ) %>%
  filter(period == 'nestling') %>%
  filter(id %in% c('HAR10', 'HAR09', 'HAR04', 'HAR05'))

sf.df <- st_as_sf(df, coords=c('lon', 'lat')) %>%
  st_set_crs('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs') %>%
  st_transform("+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs")

# Calculate MCPs
mcp <- sf.df %>%
  dplyr::select(id, geometry) %>%
  as_Spatial() %>%
  mcp.area(percent=seq(20, 100, by=10),
           unin='m', unout='ha', plotit=FALSE) %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name)

# Fix formatting so it can actually be graphed.
mcp <- pivot_longer(mcp,
  cols=c('HAR04', 'HAR05', 'HAR09', 'HAR10'), names_to='id')

# Then graph it.
ggplot(mcp, aes(percent, value, color=id)) +
  geom_point() +
  geom_path() +
  theme_classic() +
  theme(panel.grid=element_line(color='white')) +
  labs(x='Percentage location points', y='Home range area (ha)')

# Calculate 95% MCPs
mcp.95 <- sf.df %>%
  dplyr::select(id, geometry) %>%
  as_Spatial() %>%
  mcp.area(percent=95,
           unin='m', unout='ha', plotit=FALSE) %>%
  `rownames<-`('95% MCPs (ha)')

# Make a table
kable(mcp.95, digits=2, title='2019 nestling season')
