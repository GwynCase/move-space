rm(list = ls())   # Clear the workspace.
gc()            # Perform a garbage collection.

setwd('C:/Users/Gwyn/sfuvault')

# Load the data.
ska <- read.csv('Data/Telemetry/telem_all.csv', header=TRUE,
                stringsAsFactors=FALSE) %>%
  filter(nest == 'SKA2019') %>%
  drop_na()

# Create intervals for breeding chronology.

inc <- interval((ymd(20190415)), (ymd(20190510)))