install.packages("exiftoolr")

snap <- snapshot$info %>%
  rownames_to_column() %>%
  as.data.frame() %>%
  dplyr::select(filename=rowname, timestamp=ctime)

# Make it pretty.
photos <- TMC.photos %>%
  dplyr::select(filename=FileName, datetime=CreateDate,
                serial=SerialNumber) %>%
  mutate(site='TMC')

# Do the datetime thing.
photos$datetime <- ymd_hms(photos$datetime, tz='America/Vancouver')

class(photos$datetime)

# When was it recording?
photos %>% summarize(first=min(datetime), last=max(datetime),
          length=difftime(last, first))

# How many photos per day?
photos %>%
  mutate(datetime=floor_date(datetime, unit='days')) %>%
  group_by(datetime) %>%
  summarize(n())

class(sample.photos)

# Now I've re-loaded it...
df2 <- df %>%
  filter(interest != '') %>%
  dplyr::select(filename)

interest <- sample.exif %>%
  filter(FileName %in% df2$filename) %>%
  dplyr::select(SourceFile) %>%
  list()

class(files)
class(interest)

# Add columns
photos <- photos %>%
  add_column(interest='', live.chicks='', class='', family='',
             genus='', species='', common='', comments='')

# Make a toy.
df <- photos

# Split by date
cut <- split(df, week(df$date))




write.csv(photos, file=paste('TMC_photos', '_', as.character(x), sep=''),
           row.names=FALSE)


lapply(seq_along(cut), function(x)
  write.csv(cut[[x]], file=paste0('TMC_photos', x, '.csv'), row.names=FALSE))

dir.create('../data/interim/n_cam_csv')

# This works! But saves in the wrong place.
purrr::walk(seq_along(cut), function(x){
  write.csv(cut[[x]],
           file=paste('../data/interim/n_cam_csv', 'TMC_photos', '_',
                      as.character(x), '.csv', sep=''),
           row.names=FALSE)
})

