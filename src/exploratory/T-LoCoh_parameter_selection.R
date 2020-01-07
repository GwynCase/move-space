lxy.plot.sfinder(ska.lxy, delta.t=3600*c(12,24,36,48,54,60), return=TRUE)

ska.lxy <- lxy.nn.add(ska.lxy, s=0.007, a=auto.a(nnn=18, ptp=0.98))

summary(ska.lxy)


plot(ska.lhs.amixed, iso=T, ufipt=F)
