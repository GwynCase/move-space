rm(list = ls())   # Clear the workspace.
gc()            # Perform a garbage collection.

# Make a table showing date range

df %>%
  select(site, id, datetime) %>%
  group_by(site, id) %>%
  summarize(first=min(datetime), last=max(datetime), length=difftime(last, first)) %>%
  kable(col.names=c('site', 'id', 'first location', 'last location', 'time period'),
        digits=2)

# Define the breeding periods.
dates <- tibble(per=c('s.inc', 'e.inc', 's.nst', 'e.nst', 's.flg', 'e.flg',
                    's.wnt', 'e.wnt', 's.wn2', 'e.wn2'),
                date=c(20190415, 20190510, 20190511, 20190710, 20190711, 20190901,
                           20190902, 20191231, 20190101, 20190414)) %>%
  transmute(per, date=ymd(date, tz='America/Vancouver'))

# Create intervals.
nestling <- interval(dates$date[3], dates$date[4])
fledgling <- interval(dates$date[5], dates$date[6])
winter1 <- interval(dates$date[7], dates$date[8])
winter2 <- interval(dates$date[7], dates$date[8])
incubation <- interval(dates$date[1], dates$date[2])

winter2 <- interval(ymd(20190101), ymd(20190414))
incubation <- interval(ymd(20190415), ymd(20190510))
nestling <- interval(ymd(20190511), ymd(20190710))
fledgling <- interval(ymd(20190711), ymd(20190901))
winter1 <- interval(ymd(20190902), ymd(20191231))

# Define periods.

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
  group_by(site, period) %>%
  summarize(n()) %>%
  kable(col.names=c('site', 'period', 'locations'))
