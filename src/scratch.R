
ggplot(visit.stats, aes(x=timeSinceLastVisit)) +
  geom_density() +
  theme_classic()

head(visit.stats)

ggplot(visit.stats, aes(x=time, y=timeSinceLastVisit)) +
  geom_boxplot() +
  theme_classic() +
  geom_jitter(alpha=0.25) +
  labs(x='entrance time', y='visit duration')

foraging.stats %>% drop_na(timeSinceLastVisit)

ggplot(visit.stats, aes(x=timeSinceLastVisit, y=timeInside)) +
  geom_point() +
  theme_classic()
