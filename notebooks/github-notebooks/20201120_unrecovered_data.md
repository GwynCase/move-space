Unrecovered data
================

Trying to see how much data we do have compared to how much data we
should have.

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
```

I won’t bother doing this with number of points, but I will look at
days, and maybe break it down in breeding season days and winter days.

``` r
# Transform date into a date.
telemetry.sites <- telemetry.sites %>% mutate(date=ymd(date))

# Twist wide so each id gets its own row.
captures <- select(telemetry.sites, m_tag, f_tag, year, date, site, nest) %>%
  pivot_longer(!c(year, date, site, nest), names_to='sex', values_to='id') %>%
  drop_na(id) %>%
  mutate(sex=case_when(
    sex == 'm_tag' ~ 'm',
    sex == 'f_tag' ~ 'f'
  )) %>% 
  distinct(nest, id, .keep_all=TRUE)

# Get today's date.
now <- today()

# Calculate difference between tagging date and today's date.
captures <- captures %>% mutate(e.time=case_when(
  year == 2018 ~ ymd('2018-12-31') - date,
  TRUE ~ now - date))
```

Note that HAR07 died sometime in the winter of 2018, so it isn’t fair to
count all of the elapsed time since he was tagged–it’’s cut off at the
end of 2018.

Now calculate how many days of data there actually are. Again, I’ll trim
HAR07’s data to the end of 2018.

``` r
# Trim HAR07 points.
df <- df %>% filter(id != 'HAR07' | datetime <= ymd('2018-12-31'))

# Calculate days of data.
avail.data <- df %>% group_by(id) %>% 
  mutate(min=min(date), max=max(date), n.points=n(), period=max-min) %>% 
  distinct(id, site, n.points, min, max, period) 

# Then join them together.
t.data <- select(avail.data, id, site, period) %>% right_join(captures, by=c('site', 'id')) %>% 
  mutate(period=as.numeric(period), e.time=as.numeric(e.time)) %>% 
  replace_na(list(period=0))

# Calculate percentage of days retrieved.
t.data %>% mutate(p.time=period/e.time*100)
```

    ## # A tibble: 13 x 9
    ## # Groups:   id [12]
    ##    id    site  period  year date       nest    sex   e.time p.time
    ##    <chr> <chr>  <dbl> <dbl> <date>     <chr>   <chr>  <dbl>  <dbl>
    ##  1 HAR02 RLK       25  2020 2020-06-13 RLK2020 f        310   8.06
    ##  2 HAR03 GRV       20  2020 2020-06-06 GRV2020 f        317   6.31
    ##  3 HAR12 FMT        3  2020 2020-06-25 FMT2020 f        298   1.01
    ##  4 HAR04 RLK       16  2019 2019-06-22 RLK2019 m        667   2.40
    ##  5 HAR05 SKA       73  2019 2019-06-23 SKA2019 m        666  11.0 
    ##  6 HAR08 TCR       17  2019 2019-06-10 TCR2019 f        679   2.50
    ##  7 HAR09 MTC       61  2019 2019-06-11 MTC2019 m        678   9.00
    ##  8 HAR10 MTC       58  2019 2019-06-11 MTC2019 f        678   8.55
    ##  9 HAR07 TCR      160  2018 2018-07-08 TCR2018 m        176  90.9 
    ## 10 HAR11 UTZ        0  2019 2019-06-26 UTZ2019 f        663   0   
    ## 11 HAR06 PNC        0  2020 2020-06-18 PNC2020 f        305   0   
    ## 12 HAR01 PCR        0  2020 2020-06-29 PCR2020 f        294   0   
    ## 13 HAR07 STV        0  2020 2020-07-09 SVT2020 f        284   0

Ok, so that’s per bird. How about overall?

``` r
t.data %>% ungroup() %>% summarize(period=sum(period), e.time=sum(e.time)) %>% 
  mutate(p.time=period/e.time*100)
```

    ## # A tibble: 1 x 3
    ##   period e.time p.time
    ##    <dbl>  <dbl>  <dbl>
    ## 1    433   6015   7.20

Ooof. So we have only retrieved about 10% of the days of data we should
have. Most of that’s during the winter, though, yes? Well, at this point
maybe not…

``` r
# Define breeding season.
breeding.2018 <- interval(ymd(20180420), ymd(20180915))
breeding.2019 <- interval(ymd(20190420), ymd(20190915))
breeding.2020 <- interval(ymd(20200420), ymd(20200915))

# Select only points that fall within the breeding season.
df.breeding <- df %>% 
  filter(date %within% c(breeding.2018, breeding.2019, breeding.2020))

# Calculate days of data.
avail.data.br <- df.breeding %>% group_by(id) %>% 
  mutate(min=min(date), max=max(date), n.points=n(), period=max-min) %>% 
  distinct(id, site, n.points, min, max, period) 

# Then join them together.
t.data.br <- select(avail.data.br, id, site, period) %>% right_join(captures, by=c('site', 'id')) %>% 
  mutate(period=as.numeric(period), e.time=as.numeric(e.time)) %>% 
  replace_na(list(period=0))

# Calculate percentage of days retrieved.
t.data.br %>% mutate(p.time=period/e.time*100)
```

    ## # A tibble: 13 x 9
    ## # Groups:   id [12]
    ##    id    site  period  year date       nest    sex   e.time p.time
    ##    <chr> <chr>  <dbl> <dbl> <date>     <chr>   <chr>  <dbl>  <dbl>
    ##  1 HAR02 RLK       25  2020 2020-06-13 RLK2020 f        310   8.06
    ##  2 HAR03 GRV       20  2020 2020-06-06 GRV2020 f        317   6.31
    ##  3 HAR12 FMT        3  2020 2020-06-25 FMT2020 f        298   1.01
    ##  4 HAR04 RLK       16  2019 2019-06-22 RLK2019 m        667   2.40
    ##  5 HAR05 SKA       73  2019 2019-06-23 SKA2019 m        666  11.0 
    ##  6 HAR08 TCR       17  2019 2019-06-10 TCR2019 f        679   2.50
    ##  7 HAR09 MTC       61  2019 2019-06-11 MTC2019 m        678   9.00
    ##  8 HAR10 MTC       58  2019 2019-06-11 MTC2019 f        678   8.55
    ##  9 HAR07 TCR       68  2018 2018-07-08 TCR2018 m        176  38.6 
    ## 10 HAR11 UTZ        0  2019 2019-06-26 UTZ2019 f        663   0   
    ## 11 HAR06 PNC        0  2020 2020-06-18 PNC2020 f        305   0   
    ## 12 HAR01 PCR        0  2020 2020-06-29 PCR2020 f        294   0   
    ## 13 HAR07 STV        0  2020 2020-07-09 SVT2020 f        284   0

And overall?

``` r
t.data.br %>% ungroup() %>% summarize(period=sum(period), e.time=sum(e.time)) %>% 
  mutate(p.time=period/e.time*100)
```

    ## # A tibble: 1 x 3
    ##   period e.time p.time
    ##    <dbl>  <dbl>  <dbl>
    ## 1    341   6015   5.67

Oh, wow, worse. How does that math even work??

The obvious question is *where* are all these data going? The most
depressing option is tag mortality.

  - Blakely etal 2019 had 3/20 birds disappear over 3 years, using the
    same GPS logger tech and backpack mounts we used.
  - Beier & Drennan 1999 lost 0/20 birds over 2 years, using VHF and
    backpacks. They report no mortality but do not explicitly state
    there were no losses.
  - Boal etal 2003 lost 2/33 birds over 2 years wearing VHF and
    backpacks to predation. An additional bird lost its tag. (Also note
    that 3 females could not be included bc they had too few points.)
  - McCLaren 2005 13/63 birds in first year after tagging (though study
    lasted 5 years) with VHF and backpacks. Did not get enough locations
    to generate a single homerange estimate.
  - Squires & Ruggiero 1995 lost 3/4 birds tagged with VHF and
    backpacks. This was specifically winter study so low survival
    expected.

Actual studies of survival are variable. Steenhof etal 2006 found
survival nearly halved for tagged prairie falcons, but Sergio etal 2015
found no significant effect in black kites.

Survival on Kaibab was has (Reynolds & Joy 1998), 0.688 for males and
0.866 for females. They also found territory turnover–a territory holder
being replaced in a subsequent year–to be 25% for males and 16% for
females.

So what actually happened to our birds?

``` r
fate <- c('breeding 2020, no data', 
          'breeding 2020', 
          'breeding 2020', 
          'present at site, no 2020 data', 
          'present at site, no 2020 data',
          'breeding 2020, no data',
          'deceased',
          'breeding 2020, no data',
          'potentially resident at unknown nest',
          'present at new site, no 2020 data',
          'present at site, no 2020 data',
          'unknown, not breeding at site',
          'breeding 2020')

t.data %>% arrange(id) %>% bind_cols(fate=fate) %>% select(!date) %>% arrange(year)
```

    ## # A tibble: 13 x 8
    ## # Groups:   id [12]
    ##    id    site  period  year nest    sex   e.time fate                           
    ##    <chr> <chr>  <dbl> <dbl> <chr>   <chr>  <dbl> <chr>                          
    ##  1 HAR07 TCR      160  2018 TCR2018 m        176 deceased                       
    ##  2 HAR04 RLK       16  2019 RLK2019 m        667 present at site, no 2020 data  
    ##  3 HAR05 SKA       73  2019 SKA2019 m        666 present at site, no 2020 data  
    ##  4 HAR08 TCR       17  2019 TCR2019 f        679 potentially resident at unknow~
    ##  5 HAR09 MTC       61  2019 MTC2019 m        678 present at new site, no 2020 d~
    ##  6 HAR10 MTC       58  2019 MTC2019 f        678 present at site, no 2020 data  
    ##  7 HAR11 UTZ        0  2019 UTZ2019 f        663 unknown, not breeding at site  
    ##  8 HAR01 PCR        0  2020 PCR2020 f        294 breeding 2020, no data         
    ##  9 HAR02 RLK       25  2020 RLK2020 f        310 breeding 2020                  
    ## 10 HAR03 GRV       20  2020 GRV2020 f        317 breeding 2020                  
    ## 11 HAR06 PNC        0  2020 PNC2020 f        305 breeding 2020, no data         
    ## 12 HAR07 STV        0  2020 SVT2020 f        284 breeding 2020, no data         
    ## 13 HAR12 FMT        3  2020 FMT2020 f        298 breeding 2020

Not actually as bad as it sounds.
