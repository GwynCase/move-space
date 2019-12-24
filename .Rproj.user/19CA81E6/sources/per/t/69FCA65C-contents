options(scipen=999)

# Read in the data.
df <- read.csv('data/processed/telem_all.csv',
               header=TRUE, stringsAsFactors=FALSE) %>%
  drop_na('lat')

# Do the datetime thing.
df$datetime <- ymd_hms(df$datetime, tz='America/Vancouver')

# Do the spatial thing.
sf.df <- st_as_sf(df, coords=c('lon', 'lat')) %>%
  st_set_crs('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs') %>%
  st_transform("+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs")

##########
# Define period of interest
nestling <- interval(ymd(20190511), ymd(20190710))

# Filter desired period, tags.
ska.nest <- df %>%
  mutate(yrls=ymd(paste(2019, month(datetime), day(datetime)))) %>%
  filter(datetime %within% nestling) %>%
  filter(id == 'HAR05')

# Make a move object.
move.ska <- move(x=ska.nest$lon, y=ska.nest$lat, time=ska.nest$datetime,
                 proj=CRS('+proj=longlat'))

# Convert move object CRS to something more useful
move.ska <- spTransform(move.ska,
                        CRSobj='+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs')

hrBootstrap(x=move.ska, rep=25, unin='km', unout='km2', plot=TRUE)
##############
# 50% and 95% MCP for each tag and all points.
mcp.all <- sf.df %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  mcp.area(percent=c(50, 95),
           unin='m', unout='ha', plotit=FALSE)%>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name)

# Add new columns
mcp.all <- mcp.all %>%
  add_column(method='MCP', period='total')

# Fix formatting so it can actually be graphed.
mcp.all <- pivot_longer(mcp.all,
  cols=c('HAR04', 'HAR05', 'HAR07', 'HAR08', 'HAR09', 'HAR10'), names_to='id')

# Create intervals.
winter2 <- interval(ymd(20190101), ymd(20190414))
incubation <- interval(ymd(20190415), ymd(20190510))
nestling <- interval(ymd(20190511), ymd(20190710))
fledgling <- interval(ymd(20190711), ymd(20190901))
winter1 <- interval(ymd(20190902), ymd(20191231))

# Assign locations to period.
sf.df<- sf.df %>%
  dplyr::select(id, datetime, geometry) %>%
  mutate(yrls=ymd(paste(2019, month(datetime), day(datetime))),
         period=case_when(
           yrls %within% incubation ~ 'incubation',
           yrls %within% nestling ~ 'nestling',
           yrls %within% fledgling ~ 'fledgling',
           yrls %within% winter1 ~ 'winter',
           yrls %within% winter2 ~ 'winter'
         )
  )

# 50% and 95% MCP for each tag and nestling points.
mcp.nest <- sf.df %>%
  filter(period == 'nestling') %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  mcp.area(percent=c(50, 95),
           unin='m', unout='ha', plotit=FALSE)%>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name)

mcp.nest <- mcp.nest %>%
  add_column(method='MCP', period='nestling') %>%
  pivot_longer(cols=c('HAR04', 'HAR05', 'HAR07', 'HAR08', 'HAR09', 'HAR10'),
               names_to='id')

# 50% and 95% MCP for each tag and fledgling points.
mcp.fledge <- sf.df %>%
  filter(period == 'fledgling') %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  mcp.area(percent=c(50, 95),
           unin='m', unout='ha', plotit=FALSE)%>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name)

mcp.fledge <- mcp.fledge %>%
  add_column(method='MCP', period='fledgling') %>%
  pivot_longer(cols=c('HAR05', 'HAR07'),
               names_to='id')

# 50% and 95% MCP for each tag and winter points.
mcp.wint <- sf.df %>%
  filter(period == 'winter') %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  mcp.area(percent=c(50, 95),
           unin='m', unout='ha', plotit=FALSE)%>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name)

mcp.wint <- mcp.wint %>%
  add_column(method='MCP', period='winter') %>%
  pivot_longer(cols=c('HAR05', 'HAR07'),
               names_to='id')

# Now make a kud.
kud.all <- sf.df %>%
  dplyr::select(id, geometry) %>%
  as_Spatial() %>%
  kernelUD(extent=0.25, grid=100) %>%
  kernel.area(percent=95, unin='m', unout='ha') %>%
  as.data.frame %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name) %>%
  add_column(method='KDE', period='total') %>%
  pivot_longer(cols=c('HAR04', 'HAR05', 'HAR07', 'HAR08', 'HAR09', 'HAR10'),
               names_to='id')

# And for 50%.
k.a.50 <- sf.df %>%
  dplyr::select(id, geometry) %>%
  as_Spatial() %>%
  kernelUD(extent=0.25, grid=100) %>%
  kernel.area(percent=50, unin='m', unout='ha') %>%
  as.data.frame %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name) %>%
  add_column(method='KDE', period='total') %>%
  pivot_longer(cols=c('HAR04', 'HAR05', 'HAR07', 'HAR08', 'HAR09', 'HAR10'),
               names_to='id')

# For nestling 95%.
k.n.95 <- sf.df %>%
  filter(period == 'nestling') %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  kernelUD(extent=0.3, grid=100) %>%
  kernel.area(percent=95, unin='m', unout='ha') %>%
  as.data.frame %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name) %>%
  add_column(method='KDE', period='nestling') %>%
  pivot_longer(cols=c('HAR04', 'HAR05', 'HAR07', 'HAR08', 'HAR09', 'HAR10'),
               names_to='id')

# For neslting 50%.
k.n.50 <- sf.df %>%
  filter(period == 'nestling') %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  kernelUD(extent=0.3, grid=100) %>%
  kernel.area(percent=50, unin='m', unout='ha') %>%
  as.data.frame %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name) %>%
  add_column(method='KDE', period='nestling') %>%
  pivot_longer(cols=c('HAR04', 'HAR05', 'HAR07', 'HAR08', 'HAR09', 'HAR10'),
               names_to='id')

# For fledgling 95%
k.f.95 <- sf.df %>%
  filter(period == 'fledgling') %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  kernelUD(extent=0.3, grid=100) %>%
  kernel.area(percent=95, unin='m', unout='ha') %>%
  as.data.frame %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name) %>%
  add_column(method='KDE', period='fledgling') %>%
  pivot_longer(cols=c('HAR05', 'HAR07'),
               names_to='id')

k.f.50 <- sf.df %>%
  filter(period == 'fledgling') %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  kernelUD(extent=0.3, grid=100) %>%
  kernel.area(percent=50, unin='m', unout='ha') %>%
  as.data.frame %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name) %>%
  add_column(method='KDE', period='fledgling') %>%
  pivot_longer(cols=c('HAR05', 'HAR07'),
               names_to='id')

# And for winter NOT WORKING
k.w.95 <- sf.df %>%
  filter(period == 'winter') %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  kernelUD(extent=0.3, grid=100) %>%
  kernel.area(percent=95, unin='m', unout='ha') %>%
  as.data.frame %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name) %>%
  add_column(method='KDE', period='winter') %>%
  pivot_longer(cols=c('HAR05', 'HAR07'),
               names_to='id')

k.w.50 <- sf.df %>%
  filter(period == 'winter') %>%
  dplyr::select(geometry, id) %>%
  as_Spatial() %>%
  kernelUD(extent=0.3, grid=100) %>%
  kernel.area(percent=50, unin='m', unout='ha') %>%
  as.data.frame %>%
  rownames_to_column(var='name') %>%
  mutate(percent=as.numeric(name)) %>%
  dplyr::select(-name) %>%
  add_column(method='KDE', period='winter') %>%
  pivot_longer(cols=c('HAR05', 'HAR07'),
               names_to='id')

# Merge everything.
hr <- bind_rows(mcp.all, mcp.nest, mcp.fledge, mcp.wint, kud.all, k.a.50,
                k.n.95, k.n.50, k.f.95, k.f.50)

hr <- hr %>%
  pivot_wider(names_from=period, values_from=value) %>%
  dplyr::select(id, method, percent, total, nestling, fledgling, winter) %>%
  arrange(id, method, percent)

# Create some summary stuff.
df.sum <- df %>%
  dplyr::select(id, datetime) %>%
  mutate(yrls=ymd(paste(2019, month(datetime), day(datetime))),
         period=case_when(
           yrls %within% incubation ~ 'incubation',
           yrls %within% nestling ~ 'nestling',
           yrls %within% fledgling ~ 'fledgling',
           yrls %within% winter1 ~ 'winter',
           yrls %within% winter2 ~ 'winter'
         )
  ) %>%
  group_by(id, period) %>%
  summarize(n=n())

df.sum <- df.sum %>%
  pivot_wider(names_from=period, values_from=n, values_fill=list(n=0)) %>%
  mutate(total=incubation+nestling+fledgling+winter, percent=100, method='n(pts)') %>%
  dplyr::select(id, method, percent, total, incubation, nestling, fledgling, winter)

# Add to main table.
hr2 <- bind_rows(hr, df.sum)

hr2 <- hr2 %>%
  arrange(id, method, percent)
