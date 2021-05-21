# A better way to clean the telemetry data.

# Set the working directory.
# setwd('C:/Users/Gwyn/sfuvault/move-space')

# Load some libraries.
library(tidyverse)
library(lubridate)

## First of all, we need to bring in the raw data.
## The raw .csv files have different naming conventions, but all have "HAR" in the name.
## This means we can select all files containing "HAR" and load them at once.

# Make a list of the files containing "HAR".
 file.list <- list.files('../data/raw', pattern='HAR', full.names=TRUE)

# Ridiculously, make a function to read the data in properly.
read <- function(x) {
  read_delim(x, ';')
}

# Load all of the files in the list.
df <- lapply(file.list, read)

## Because the HAR07 ("OG") data is fucked up, it doesn't load properly this way.

# Figure out which item is broken.
# str(df)   # df[[7]]

# Drop it from the data set.
df[[7]] <- NULL

# Now reshape remaining data into one data frame.
# Make sure this one variable is numeric, it's important later.
df <- bind_rows(df) #%>%
 # mutate(Speed=as.numeric(Speed))

## We can bring in the HAR07 data separately.

# Load HAR07 csv.
# We'll have to rename all these columns so they match the rest of the data.
HAR07 <- read_csv("../data/raw/HAR07_RAW_2018-07-08_2019-05-09.csv") %>%
  rename(Latitude=Lat,
         Longitude=Long,
         `Searching time`=SearchT,
         `Logger ID`=LoggerID,
         Temperature=Temp,
         `No GPS - timeout`=NoGPS)

# Because HAR07 died sometime in winter 2018/2019, I'll drop all 2019 points.
HAR07 <- filter(HAR07, Year != 2019)

# Add to the main dataframe.
df <- bind_rows(df, HAR07)

## Now we'll do a little cleanup on the data.

# Make a single datetime column.
df$datetime <-
  strptime(paste(df$Year, df$Month, df$Day, df$Hour, df$Minute, df$Second),
           format='%Y%m%d%H%M%S', tz='UTC')

# Then convert the datetime to the correct timezone.
# Convert timezone from UTC to PT.
df$datetime <- with_tz(df$datetime, tzone = "America/Los_Angeles")

# Also add separate columns for date and time.
df$date <- date(df$datetime)
df$time <- format(ymd_hms(df$datetime), '%H:%M%S')

# Make a list of all the extra columns we don't need.
e.cols <- c('Month', 'Day', 'Hour', 'Minute', 'Second',
            'Altitude', 'Div up', 'Div down', 'No GPS - diving', 'Diving duration',
            'Raw latitude', 'Raw Longitude', 'Decision voltage', 'Milisecond',
            'Acc_X', 'Acc_Y', 'Acc_Z')

# Filter them out of the data set.
df <- select(df, !any_of(e.cols))

# Rename the remaining columns in a reasonable, consistent way.
df <- rename(df, id='Logger ID',
               lat='Latitude',
               lon='Longitude',
               speed='Speed',
               s.time='Searching time',
               volt='Voltage',
               temp='Temperature',
               no.fix='No GPS - timeout',
               at.base='In range',
               year='Year',
               datetime=datetime)


## When the bird is at the base station, no location is recorded.
## But since we know where the bird was, we can fill in the location with the nest coordinates.

# Read in table of nest coordinates.
telemetry.sites <- read_csv('../data/processed/telemetry_sites.csv')

# Twist the data a little so it's easier to manage.
nest.coords <- select(telemetry.sites, lat, lon, m_tag, f_tag, year, site, nest) %>%
  pivot_longer(!c(lat, lon, year, site, nest), names_to='sex', values_to='id') %>%
  drop_na(id) %>% rename(n.lat=lat, n.lon=lon) %>%
  mutate(sex=case_when(
    sex == 'm_tag' ~ 'm',
    sex == 'f_tag' ~ 'f'
  ))

# Now join to main data frame.
df <- left_join(df, nest.coords, by=c('id', 'year'))

# Fill missing coordinates when bird is at the nest.
df <- df %>% mutate(
  lat=case_when(
    at.base == 1 & is.na(lat) ~ n.lat,
    TRUE ~ lat
  ),
  lon=case_when(
    at.base == 1 & is.na(lon) ~ n.lon,
    TRUE ~ lon
  )
)

## The tags record 1 + NA for some variables, which is annoying.
## It's much tidier if we fill the NAs with 0s.

# Replace NAs for appropriate variables.

df <- df %>% replace_na(list(no.fix=0, at.base=0, s.time=0))

## It turns out there is a problem with duplicates, though strangely only for the 2020 data.
## Looking closer, there are sometimes slight differences in location, temp, etc. between them.
## However, they look close enough that I feel comfortable simply removing the duplicates.

# Remove any duplicates.
df <- df %>% distinct(id, datetime, .keep_all=TRUE)

# Also remove any "points" that were missed--times when no locations were recorded.
df <- df %>% filter(!is.na(lat))

# Finally, remove the nest coordinates again.
df <- df %>% select(!c(n.lat, n.lon))

## There are a few data errors that need to get manually cleared up.
## This is very tiresome but there doesn't seem to be a better way of dealing with it.

# Some HAR09 points were taken in Vancouver; remove them.
df <- df %>% filter(id != 'HAR09' | lat >= 50)

# Do the exact same for HAR10.
df <- df %>% filter(id != 'HAR10' | lat >= 50)

# There is an erroneous point for HAR07 in Washington.
df <- df %>% filter(id != 'HAR07' | lat >= 47)

# There is also an erroneous point for HAR02 somewhere in Nunavut.
df <- df %>% filter(id != 'HAR02' | lat <= 52)

# The HAR07 tag was recycled to STV. Rename this id to avoid confusion.
df <- df %>% mutate(id=case_when(
  id == 'HAR07' & year >= 2020 ~ 'HAR007',
  TRUE ~ id
))

# The site name for STV also needs to be fixed, since it will have been bound incorrectly.
df <- df %>% mutate(site=case_when(
  id == 'HAR007' ~ 'STV',
  TRUE ~ site
))



