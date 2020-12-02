Maximum distance
================

A more graceful calculation of maximum distance.

``` r
# Import conflict settings.
source('../src/conflicted.R')

#Load some libraries.
library(tidyverse)
library(sf)
library(ggplot2)
library(extrafont)

# Load telemetry data.
source('../src/clean_telemetry.R')

# Define breeding season.
breeding.2018 <- interval(ymd(20180420), ymd(20180915))
breeding.2019 <- interval(ymd(20190420), ymd(20190915))
breeding.2020 <- interval(ymd(20200420), ymd(20200915))

# Select only points that fall within the breeding season.
df.br <- df %>% 
  filter(date %within% c(breeding.2018, breeding.2019, breeding.2020))

# Try to fix HAR07 issue.
df.br <- df.br %>% filter(id != 'HAR07' | lat >= 47)
df.br <- df.br %>% filter(id != 'HAR02' | lat >= 52)
```

First join the nest coordinates onto the telemetry points. Of course,
ironically, this is a step I undid during the cleaning phase.

``` r
# Convert nest coordinates to UTMs.
nest.sf <- nest.coords %>% st_as_sf(coords=c('n.lon', 'n.lat')) %>%
  st_set_crs('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs') %>%
  st_transform("+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs")

nest.sf <- nest.sf %>% mutate(n.xcoord = unlist(map(nest.sf$geometry,1)),
                              n.ycoord = unlist(map(nest.sf$geometry,2))) %>%
  data.frame()

# Convert location points to UTMs.
df.br.sf <- df.br %>% 
  st_as_sf(coords=c('lon', 'lat')) %>%
  st_set_crs('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs') %>%
  st_transform("+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs")

df.br.sf <- df.br.sf %>% mutate(xcoord = unlist(map(df.br.sf$geometry,1)),
                          ycoord = unlist(map(df.br.sf$geometry,2))) %>%
  data.frame()

# Bind nest coordinates to location points.
bind.sf <- left_join(df.br.sf, nest.sf, by=c('id', 'year', 'site', 'sex', 'nest'))
```

Then (hopefully) calculate the maximum distance for each.

``` r
max.dist <- mutate(bind.sf, dist=sqrt((xcoord-n.xcoord)^2 + (ycoord-n.ycoord)^2)) %>%
  group_by(id) %>% 
  arrange(desc(dist)) %>% 
  slice(1) %>% 
  select(id, dist, sex)

max.dist
```

    ## # A tibble: 8 x 3
    ## # Groups:   id [8]
    ##   id      dist sex  
    ##   <chr>  <dbl> <chr>
    ## 1 HAR03 2444.  f    
    ## 2 HAR04 7773.  m    
    ## 3 HAR05 8026.  m    
    ## 4 HAR07 7977.  m    
    ## 5 HAR08   76.5 f    
    ## 6 HAR09 4413.  m    
    ## 7 HAR10 5459.  f    
    ## 8 HAR12 2304.  f

Wow, I had a lot of erroneous points to take care of, but now that
that’s taken care of, this looks pretty ok. So let’s look at the
average.

``` r
max.dist %>% ungroup() %>% summarize(mean(dist))
```

    ## # A tibble: 1 x 1
    ##   `mean(dist)`
    ##          <dbl>
    ## 1        4809.

``` r
max.dist %>% ungroup() %>% group_by(sex) %>% summarize(mean(dist))
```

    ## # A tibble: 2 x 2
    ##   sex   `mean(dist)`
    ##   <chr>        <dbl>
    ## 1 f            2571.
    ## 2 m            7047.

And what does this work out to in area?

``` r
# Name the radius.
r <- max.dist %>% ungroup() %>% group_by(sex) %>% summarize(mean=mean(dist)) %>%
  filter(sex == 'm') %>% select(mean) %>% 
  as.numeric()

# Calculate area of a circle (in m2).
a <- pi*r^2

# Convert to ha.
a.ha <- a/10000

# What is it?
a.ha
```

    ## [1] 15602.21
