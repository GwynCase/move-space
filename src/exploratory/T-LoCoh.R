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

# Try thinning.
ska.thin <- lxy.thin.byfreq(ska.lxy, byfreq=TRUE, samp.freq=960, lcm.round=120)
lxy.plot.freq(ska.thin, cp=T)

# Now set s and k.
ska.lxy <- lxy.nn.add(ska.lxy, s=0, k=25)

# And make hull plots.
ska.lhs <- lxy.lhs(ska.lxy, k=3*3:8, s=0)
plot(ska.lhs, hulls=TRUE, figs.per.page=6)

# Add isopleths.
ska.lhs <- lhs.iso.add(ska.lhs)
plot(ska.lhs, iso=TRUE, figs.per.page=1)

plot(ska.lhs, iso=T, k=9, allpts=T, cex.allpts=0.1, col.allpts="gray30", ufipt=F)
plot(ska.lhs, iso=T, k=12, allpts=T, cex.allpts=0.1, col.allpts="gray30", ufipt=F)
plot(ska.lhs, iso=T, k=15, allpts=T, cex.allpts=0.1, col.allpts="gray30", ufipt=F)
plot(ska.lhs, iso=T, k=18, allpts=T, cex.allpts=0.1, col.allpts="gray30", ufipt=F)
plot(ska.lhs, iso=T, k=21, allpts=T, cex.allpts=0.1, col.allpts="gray30", ufipt=F)
plot(ska.lhs, iso=T, k=24, allpts=T, cex.allpts=0.1, col.allpts="gray30", ufipt=F)

# The 18 and 21 look nice. Let's try some other metrics.
lhs.plot.isoarea(ska.lhs)
lhs.plot.isoear(ska.lhs)

# I think I still like k=18.

# Now to pick a s value.
ska.lxy <- lxy.ptsh.add(ska.lxy)
# Some value between 0.005 and 0.04 seems appropriate based on this method.

lxy.plot.pt2ctr(ska.lxy)
# A 24-hour timescale seems reasonable based on this.

s.find <- lxy.plot.sfinder(ska.lxy, delta.t=3600*c(12,24,36,48,54,60))
s.parity.24hrs <- s.find[[1]]$svals[["86400"]]
median(s.parity.24hrs)

# Add s value to hull object.
ska.lxy <- lxy.nn.add(ska.lxy, s=0.007, k=18)

summary(ska.lxy)
