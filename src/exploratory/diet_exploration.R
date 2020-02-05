csv.list <- list.files('C:/Users/Gwyn/sfuvault/move-space/data/interim',
           pattern='TMC_photos', full.names=TRUE)

df <-
  csv.list %>%
  map_df(~read_csv(., col_types = cols(.default = "c")))

photos_4 <-
  read.csv('C:/Users/Gwyn/sfuvault/move-space/data/interim/TMC_photos_4.csv')

photos_4.old <-
  read_csv('C:/Users/Gwyn/sfuvault/move-space/data/interim/n_cam_csv/TMC_photos_4.csv')

photos_4$datetime <- as.character(photos_4.old$datetime)

write.csv(photos_4,
    file='C:/Users/Gwyn/sfuvault/move-space/data/interim/TMC_photos_4_patch.csv',
        row.names=FALSE)

# Remove the "doube" csv from the list.
csv.list <- csv.list[-11]

# And start over.
photos.01 <-
  read.csv('C:/Users/Gwyn/sfuvault/move-space/data/interim/TMC_photos_1.csv', header=TRUE, stringsAsFactors=FALSE)

photos.02 <-
  read.csv('C:/Users/Gwyn/sfuvault/move-space/data/interim/TMC_photos_2.csv', header=TRUE, stringsAsFactors=FALSE)

photos.03 <-
  read.csv('C:/Users/Gwyn/sfuvault/move-space/data/interim/TMC_photos_3.csv', header=TRUE, stringsAsFactors=FALSE)

photos.04 <-
  read.csv('C:/Users/Gwyn/sfuvault/move-space/data/interim/TMC_photos_4.csv', header=TRUE, stringsAsFactors=FALSE)

photos.05 <-
  read.csv('C:/Users/Gwyn/sfuvault/move-space/data/interim/TMC_photos_5.csv', header=TRUE, stringsAsFactors=FALSE)

subset(df, is.na(datetime))
