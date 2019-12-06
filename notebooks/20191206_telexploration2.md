Telemetry data exploration II
================

In my last notebook I looked a bunch at missed points. For now I'd like to set aside the issue of missed points and figure out timespan.

``` r
library('lubridate')
library('tidyverse')
library('knitr')

df <- read.csv('../data/processed/telem_all.csv', header=TRUE, stringsAsFactors=FALSE)

# Convert times and dates immediately, just to get it over with.
df$datetime <- ymd_hms(df$datetime, tz='America/Vancouver')

# Examine the date range for each bird.
df %>%
  select(site, id, datetime) %>%
  group_by(site, id) %>%
  summarize(first=min(datetime), last=max(datetime), 
            length=difftime(last, first)) %>%
  kable(col.names=c('site', 'id', 'first location', 'last location', 
                      'time period'), digits = 2)
```

| site | id    | first location      | last location       | time period |
|:-----|:------|:--------------------|:--------------------|:------------|
| MTC  | HAR09 | 2019-06-11 13:41:00 | 2019-07-02 09:01:02 | 20.81 days  |
| MTC  | HAR10 | 2019-06-13 13:49:42 | 2019-06-29 18:57:57 | 16.21 days  |
| RLK  | HAR04 | 2019-06-22 14:16:00 | 2019-07-08 13:17:00 | 15.96 days  |
| SKA  | HAR05 | 2019-06-23 15:38:00 | 2019-09-04 15:26:00 | 72.99 days  |
| TCR  | HAR07 | 2018-07-08 13:37:00 | 2019-05-08 18:59:48 | 304.22 days |
| TCR  | HAR08 | 2019-06-10 12:38:40 | 2019-06-27 19:59:09 | 17.31 days  |

Next I want to see how many points are available for each time period. A goshawk's year can be divided into different stages (courtship, incubation, nestling, fledgling, and winter/nonbreeding). Working from McLaren et al.'s Science-Based Guidelines for Managing Northern Goshawk Breeding Areas in Coastal British Columbia, I settled on these dates:

-   Incubation: 15 April - 10 May
-   Nestling: 11 May - 10 July
-   Fledgling: 11 July - 1 September
-   Winter: 2 September - 14 April

These are a bit arbitrary because McClaren's dates overlap and I wanted discrete categories, so I split the difference when assigning dates. They also don't have dates for courtship, so I lumped that in with winter for now.

``` r
# Create intervals.
winter2 <- interval(ymd(20190101), ymd(20190414))
incubation <- interval(ymd(20190415), ymd(20190510))
nestling <- interval(ymd(20190511), ymd(20190710))
fledgling <- interval(ymd(20190711), ymd(20190901))
winter1 <- interval(ymd(20190902), ymd(20191231))

df %>%
  select(id, site, no.fix, datetime) %>%
  mutate(yrls=ymd(paste(2019, month(datetime), day(datetime))),
         period=case_when(
           yrls %within% incubation ~ 'incubation',
           yrls %within% nestling ~ 'nestling',
           yrls %within% fledgling ~ 'fledgling',
           yrls %within% winter1 ~ 'winter',
           yrls %within% winter2 ~ 'winter'
           )
         ) %>%
  filter(no.fix==0) %>%
  group_by(period) %>%
  summarize(n()) %>%
  kable(col.names=c('period', 'locations'))
```

| period     |  locations|
|:-----------|----------:|
| fledgling  |       4795|
| incubation |          9|
| nestling   |       5477|
| winter     |        430|

I got this to work with a lot of help from [StackOverflow](https://stackoverflow.com/questions/59220573/dividing-data-based-on-custom-date-range/59220844?noredirect=1#comment104657786_59220844). To overcome the issue of multiple years, I had to set all of my data to the same year, which seems very silly to me but that's R for you.

There doesn't seem to be much to say about the data itself except that most of the locations come from the fledgling and nestling period, and most of those from Skaiakos and last year's Turbid (HAR07). The Turbid winter points should be treated with caution and the incubation points should be disregarded, since that tag fell off sometime during the winter.

| site | id    | period     |  locations|
|:-----|:------|:-----------|----------:|
| MTC  | HAR09 | nestling   |       1216|
| MTC  | HAR10 | nestling   |        923|
| RLK  | HAR04 | nestling   |       1597|
| SKA  | HAR05 | fledgling  |       3079|
| SKA  | HAR05 | nestling   |       1396|
| SKA  | HAR05 | winter     |        196|
| TCR  | HAR07 | fledgling  |       1716|
| TCR  | HAR07 | incubation |          9|
| TCR  | HAR07 | nestling   |        210|
| TCR  | HAR07 | winter     |        234|
| TCR  | HAR08 | nestling   |        135|
