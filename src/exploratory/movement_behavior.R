library('sp')
library('ggplot2')

# Separate out one site.
ska <- df %>% filter(site == 'SKA')

# Convert to sp and specify coordinates.
coordinates(ska) <- c('lon', 'lat')

# Define current projection.
proj4string(ska) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

# Convert to UTM.
ska <- spTransform(ska, CRS('+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs'))

# Rename from lat/lon to x/y.
colnames(ska@coords) <- c('x', 'y')

# Return to data frame because that's what moveHMM wants.
ska <- as.data.frame(ska)

# Send to moveHMM.
data <- prepData(ska, type="UTM", coordNames=c('x','y'))

# Plot it.
plot(data)

summary(data)

### Now make the move model with 2 states.

# Chech if there are steps with a length of 0.
whichzero <- which(data$step==0)
length(whichzero)/nrow(data)

# Look at the model.
m
m3

# How does it look?
plot(m)
plot(m3)

# Get out just the daytime points.
difftime(ska$datetime, ska$sunrise, units='hours')
