
ggplot(visit.stats, aes(x=date, y=timeSinceLastVisit)) +
  geom_point() +
  theme_classic() +
  facet_wrap(~id, scales='free')

ggplot(visit.stats, aes(x=date, y=timeInside)) +
  geom_point() +
  theme_classic() +
  facet_wrap(~id, scales='free')

ggplot(visit.stats, aes(x=time)) +
  geom_histogram(stat='count') +
  theme_classic() +
  facet_wrap(~id)

