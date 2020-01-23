vi.2019 %>% group_by(Nest.Status) %>%
  summarize(n())

vi.2019 %>% filter(Nest.Status == "")

no.nest <- vi.2019 %>% filter(Nest.Status == "")

head(no.nest$Nest.Status)

class(vi.2019$Nest.Status)

vi.nest.assess.2019 <- vi.2019 %>% filter(Nest.Status != "")

sites.2018 <- distinct(vi.nest.assess.2018, SiteName)
sites.2019 <- distinct(vi.nest.assess.2019, SiteName)

intersect(sites.2018, sites.2019)

class(sites.2018$SiteName)

intersect(vi.nest.assess.2018$SiteName, vi.nest.assess.2019$SiteName)

# What are the options for sign types?
distinct(vi.nest.assess.2019, Sign.Type)
distinct(vi.nest.assess.2018, SignType)

# One is a blank space. Look coloser at that.
blank.sign <- vi.2018 %>% filter(SignType == "")

# Combine the nest assessments for both years.
nest.assess <- bind_rows(vi.nest.assess.2019$SiteName,
                         vi.nest.assess.2018$SiteName, .id='year')

## Let's make a lovely table.

# Round up 2018 sites.
voucher.2018 <- as.character(voucher.2018$SiteName)

active.2018 <- vi.nest.assess.2018 %>%
  filter(NestStatus == 'Active') %>%
  dplyr::select(SiteName) %>%
  as.character()

sites.2018 <- sites.2018 %>% mutate(year=2018) %>%
  mutate(voucher=case_when(SiteName %in% voucher.2018 ~ 1,
                           TRUE ~ 0)) %>%
  mutate(active=case_when(SiteName %in% active.2018 ~ 1,
                           TRUE ~ 0))

# Round up 2019 sites.
voucher.2019 <- as.character(voucher.2019$SiteName)

active.2019 <- vi.nest.assess.2019 %>%
  filter(Nest.Status == 'Active') %>%
  dplyr::select(SiteName) %>%
  as.character()

sites.2019 <- sites.2019 %>% mutate(year=2019) %>%
  mutate(voucher=case_when(SiteName %in% voucher.2019 ~ 1,
                           TRUE ~ 0)) %>%
  mutate(active=case_when(SiteName %in% active.2019 ~ 1,
                          TRUE ~ 0))

active <- bind_rows(active.2018, active.2019) %>%
  distinct()

## NOPE. That was completely wrong, I'm using the wrong set.
class(voucher.2018)

sites <- tibble(sites.b) %>%
  rename(SiteName=sites.b)

# Mark sites that were active in 2018.
sites %>%
  mutate(a.2018=case_when(SiteName %in% active.2018 ~ 1,
                          TRUE ~ 0))

# Mark sites that were active in 2018.
sites %>%
  mutate(a.2019=case_when(SiteName %in% active.2019 ~ 1,
                          TRUE ~ 0))

# Sites with vouchers but no nest checks.
setdiff(voucher.sites$SiteName, nest.assess)

# Site that had nest checks AND vouchers in 2018
intersect(voucher.2018$SiteName, vi.nest.assess.2018$SiteName)

# Sites that had nest checks and vouchers in either year.
intersect(voucher.sites$SiteName, nest.assess) %>%
  tibble() %>%
  rename(SiteName=1) %>%
  bind_rows(sites.b) %>%
  distinct()

# Am I making this way too complicated?
sites.2019 <- vi.2019 %>% filter(Nest.Status != "") %>%
  mutate(a.2019=case_when(Nest.Status == 'Active' ~ 1,
                          TRUE ~ 0)) %>%
  mutate(v.2019=case_when(Sign.Type %in% c('RP', 'DC', 'CR', 'RP') ~ 1,
                          TRUE ~ 0)) %>%
  group_by(SiteName) %>%
  summarise(a.2019=max(a.2019), v.2019=max(v.2019)) %>%
  dplyr::select(SiteName, a.2019, v.2019)

sites.2018 <- vi.2018 %>% filter(NestStatus != "") %>%
  mutate(a.2018=case_when(NestStatus == 'Active' ~ 1,
                          TRUE ~ 0)) %>%
  mutate(v.2018=case_when(SignType %in% c('RP', 'DC', 'CR', 'RP') ~ 1,
                          TRUE ~ 0)) %>%
  group_by(SiteName) %>%
  summarise(a.2018=max(a.2018), v.2018=max(v.2018)) %>%
  dplyr::select(SiteName, a.2018, v.2018)

sites <- bind_rows(sites.2018, sites.2019) %>%
  group_by(SiteName) %>%
  summarise(a.2018=max(a.2018), v.2018=max(v.2018),
            a.2019=max(a.2019), v.2019=max(v.2019)) %>%
  replace_na(list(a.2018=NA, v.2018=0, a.2019=NA, v.2019=0))

sites$SiteName
