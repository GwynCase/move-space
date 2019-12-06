rm(list = ls())   # Clear the workspace.
gc()            # Perform a garbage collection.

setwd('C:/Users/Gwyn/sfuvault')

# Load some libraries.
library('adehabitatHR')
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
ska$date <- date(ska$date)

# Then we need to separate out the day and night points.
ska <-  getSunlightTimes(data=ska, keep=c('sunrise', 'sunset'), 
                        tz='America/Vancouver')

ska$diff.rise <- as.numeric(difftime(ska$datetime, ska$sunrise, units='hours'))
ska$diff.set <- as.numeric(difftime(ska$datetime, ska$sunset, units='hours'))


ska$t.period <- case_when(
  ska$diff.rise >= 0 & ska$diff.set <= 0 ~ 'day',
  TRUE ~ 'night'
)

ska <- filter(ska, t.period == 'day')

