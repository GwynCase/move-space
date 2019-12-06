rm(list = ls())   # Clear the workspace.
gc()            # Perform a garbage collection.

library('dplyr')
library('tidyr')
library('lubridate')
library('tidyverse')
library('knitr')
library('RColorBrewer')

# Load the data.
df <- read.csv('data/processed/telem_all.csv', header=TRUE,
                stringsAsFactors=FALSE)

# First step is always convert date and time.
df$datetime <- ymd_hms(df$datetime, tz='America/Vancouver')
df$date <- date(df$date)

# Make a basic table to look at missed values.
table(df$id, df$no.fix) %>%
  kable()

# Fine, but that doesn't have enough information.
df %>%
  select(site, id, no.fix) %>%
  group_by(site, id) %>%
  summarize(total=n(), nofix=sum(no.fix)) %>%
  mutate(fix=total-nofix, p=nofix/total * 100) %>%
  kable(col.names=c('site', 'id', 'total records', 'no fix', 'fix', '% missed'), align='l')

# It would be interesting to know how the missed fixes are distributed.
df$week <- week(df$datetime)

df %>%
  as_factor(no.fix) %>%
  count(id, week, no.fix) %>%
ggplot(aes(x=week, y=n, fill=no.fix)) +
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(values=c('gray', 'red'), name='Fixes per bird',
                    labels=c('fix', 'no fix')) +
  labs(y='Number of fixes', x='Week') +
  theme_classic() +
  theme(legend.position='bottom') +
  facet_wrap(~id)

df %>%
  mutate(no.fix=as_factor(as.character(no.fix))) %>%
           mutate(week=week(datetime)) %>%
           count(id, week, no.fix) %>%
           ggplot(aes(x=week, y=n, fill=no.fix)) +
           geom_bar(position='stack', stat='identity') +
           scale_fill_manual(values=c('gray', 'red'), name='Fixes per bird',
                             labels=c('fix', 'no fix')) +
           labs(y='Number of fixes', x='Week') +
           theme_classic() +
           theme(legend.position='bottom') +
           facet_wrap(~id)

# And within a single day?

df %>%
  as_factor(no.fix) %>%
  mutate(hour=hour(datetime)) %>%
  count(id, hour, no.fix) %>%
  ggplot(aes(x=hour, y=n, fill=no.fix)) +
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(values=c('gray', 'red'), name='Fixes per bird',
                    labels=c('fix', 'no fix')) +
  labs(y='Number of fixes', x='Time of day') +
  theme_classic() +
  theme(legend.position='bottom') +
  facet_wrap(~id)

# Create intervals for breeding chronology.

inc <- interval((ymd(20190415)), (ymd(20190510)))
