rm(list = ls())   # Clear the workspace.
gc()            # Perform a garbage collection.

setwd('C:/Users/Gwyn/sfuvault')

# Load some libraries.
library('adehabitatLT')
library('dplyr')
library('tidyr')
library('lubridate')

# Load the data.
ska <- read.csv('Data/Telemetry/telem_all.csv', header=TRUE,
                stringsAsFactors=FALSE) %>%
  filter(nest == 'SKA2019') %>%
  drop_na()

# First step is always convert time.
ska$datetime <- ymd_hms(ska$datetime, tz='America/Vancouver')

# Convert to a ltraj object.
l.ska <- as.ltraj(xy=ska[, c('lon', 'lat')], date=ska$datetime, id=ska$id)

plot(l.ska)

# Are the locations taken at regular intervals?
is.regular(l.ska)
# Nope.

# Plot the location increments (dt) by hour (3600 seconds per hour)
plotltr(l.ska, "dt/3600")
# All the spikes represent missed locations. That sucks.

# Define reference time & date in preparation to fill in NAs.
ref.tm <- strptime('2019-06-23 00:00:00', "%Y-%m-%d %H:%M:%S", 
                  tz='America/Vancouver')

# Fill in the NAs.
m.ska <- setNA(l.ska, ref.tm, 15, units='min')
plotltr(m.ska, "dt/3600")
# Well, that made it worse.

# Try rounding instead.
n.ska <- sett0(m.ska, ref.tm, 15, units='min')
plotltr(n.ska, "dt/3600")
# Nailed it.

# Let's check whether missing values are random or not.
runsNAltraj(n.ska)
# Uhhhh that's def not random. Whoops.

# Let's look at them...
plotNAltraj(n.ska)
# Really no idea how to make heads or tails out of this.

# Let's dedistribute the points evenly. Why? FOR SCIENCE!
# Uh this isn't working.
skaI <- as.ltraj(ska, typeII=FALSE)
skaI <- typeII2typeI(n.ska)
skaI <- redisltraj(skaI, 100)

# Compare them.
plot(n.ska)
plot(skaI)
