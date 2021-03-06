Telemetry tracing
================

Right from the beginning I've wanted to know if I I could use the combined camera and telemetry data to pinpoint the locations where individual prey items were captured. So here goes!

``` r
# Load some libraries.
library('tidyverse')
library('lubridate')

# Import some data.
dt <- read_csv('../data/interim/camera_corrected.csv')
tl <- read_csv('../data/processed/telemetry_2018-2019.csv')

# Only 2 sites have both cameras and telemetry (so far): MTC and RLK.
rlk.t <- tl %>% filter(site == 'RLK')
rlk.c <- dt %>% filter(site == 'RLK' & interest == 'delivery')

mtc.c <- dt %>% filter(site == 'MTC' & interest == 'delivery')
mtc.t <- tl %>% filter(id == 'HAR09')
```

I'll start by playing with the MTC data. Photos marked with "delivery" are ones where the bird was "caught in the act" of delivering prey--in other words, I have the exact timestamp of when the prey was brought to the nest.

``` r
# Create a range starting two hours before the delivery.
mtc.c <- mtc.c %>% mutate(end=datetime - hours(1), start=datetime)

# Annotate telemetry points that fall within those ranges.
mtc.t$in.range <- mtc.t$datetime %in% unlist(Map(`:`, mtc.c$start, mtc.c$end))

mtc.caps <- mtc.t %>% filter(in.range == TRUE)

nrow(mtc.caps)
```

    ## [1] 23

That gives me 23 points that might represent capture events. To see how these points compare to the rest of the bird's points for the day, I'll also pull out the full days's tracks.

``` r
# On which days do I have telemetry data for a delivery?
mtc.cap.days <- mtc.caps %>% dplyr::select(date) %>% 
  distinct()

# Annotate all telemetry locations for those days.
mtc.t$del.day <- mtc.t$date %in% mtc.cap.days$date
```

So that's pretty promising so far. I think from here I'll take it into QGIS and try to annotate the points further.

``` r
#mtc.t %>% filter(del.day == TRUE) %>% 
#  write_csv('../data/interim/')
```

Looking at these points in QGIS, there's a pretty clear capture at 8:15 on 06-13. However, the bird visits almost that exact same spot at 10:55 and again at 16:13. I don't have record of a delivery at those times, but I may have something under newprey.

``` r
# 10:55 is the probable capture event.
# Likely nest visit at 11:11.
# Another likely capture at 11:44, so I'll make that my cutoff.
visit2 <- interval(ymd_hms(20190613105500), ymd_hms(20190613114500))

dt %>% filter(site == 'MTC') %>% 
  filter(datetime %within% visit2)
```

    ## # A tibble: 2 x 16
    ##       X filename datetime            serial site  interest live.chicks class
    ##   <dbl> <chr>    <dttm>              <chr>  <chr> <chr>          <dbl> <chr>
    ## 1    99 RCNX009… 2019-06-13 11:00:00 UXP9B… MTC   <NA>              NA <NA> 
    ## 2   100 RCNX010… 2019-06-13 11:30:00 UXP9B… MTC   <NA>              NA <NA> 
    ## # … with 8 more variables: order <chr>, family <chr>, genus <chr>,
    ## #   species <chr>, common <chr>, size <chr>, comments <chr>, sex <lgl>

So two pictures, but nothing in them. That seems to scratch the idea that the bird caught something there--though he could have been trying, and just returned empty-taloned. What about the other time range?

``` r
# 16:13 is likely capture event.
# 16:29 is transit or more foraging.
# 16:44 is likely nest visit.
# 17:02 looks like back to foraging.

visit3 <- interval(ymd_hms(20190613160000), ymd_hms(20190613170000))

dt %>% filter(site == 'MTC') %>% 
  filter(datetime %within% visit3)
```

    ## # A tibble: 3 x 16
    ##       X filename datetime            serial site  interest live.chicks class
    ##   <dbl> <chr>    <dttm>              <chr>  <chr> <chr>          <dbl> <chr>
    ## 1   217 RCNX021… 2019-06-13 16:00:00 UXP9B… MTC   <NA>              NA <NA> 
    ## 2   218 RCNX021… 2019-06-13 16:30:00 UXP9B… MTC   <NA>              NA <NA> 
    ## 3   219 RCNX021… 2019-06-13 17:00:00 UXP9B… MTC   visit             NA <NA> 
    ## # … with 8 more variables: order <chr>, family <chr>, genus <chr>,
    ## #   species <chr>, common <chr>, size <chr>, comments <chr>, sex <lgl>

Well, there was a visit from the adults at 17:00, but the female's tag data shows that she was hanging around the nest anyway so it could have been her.
