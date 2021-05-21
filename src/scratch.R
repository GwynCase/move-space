df %>% mutate(xcoord = unlist(map(df$geometry,1)),
                    ycoord = unlist(map(df$geometry,2))) %>%
  data.frame() %>% class()

test <- df %>% mutate(xcoord = unlist(map(df$geometry,1)),
                      ycoord = unlist(map(df$geometry,2))) %>%
  data.frame()

test %>% class()
class(df)

test %>% st_as_sf(coords='geometry')
class(test$geometry)
