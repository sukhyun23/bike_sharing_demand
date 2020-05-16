# source ------------------------------------------------------------------
source('./R/data_cleansing.R')

# remove trend

# weekend : yes
# 1. casual
# 2. registered
# 3. count

data_mean <- data_tr[
  ,
  .(
    mean_casual = mean(casual),
    mean_registered = mean(registered), 
    mean_count = mean(count)
  ),
  by = c('weekend', 'hour')
]
data_mean <- data_mean[order(weekend, hour), ]

data_pre <- data_tr[data_mean, on = c('weekend', 'hour')]
data_pre$casual <- data_pre$casual - data_pre$mean_casual
data_pre$registered <- data_pre$registered - data_pre$mean_registered
data_pre$count <- data_pre$count - data_pre$mean_count

qqnorm(data_pre$count)
qqline(data_pre$count)
hist(data_pre$count)

# challenge
# modeling separately by weekend


qqnorm(data_pre$registered)
qqline(data_pre$registered)
hist(data_pre$registered)


qqnorm(data_pre$casual)
qqline(data_pre$casual)
hist(data_pre$casual)


#
ggplot(data_tr, aes(x=temp, y=count)) +
  geom_point() + facet_grid(weather~season)

ggplot(data_tr, aes(x=temp, y=count)) +
  geom_point() + facet_grid(holiday~season)

ggplot(data_tr, aes(x=temp, y=count)) +
  geom_point() + facet_grid(weekend~season)


ggplot(data_pre, aes(x=temp, y=count)) +
  geom_point() + facet_grid(weather~season)

ggplot(data_pre, aes(x=temp, y=count)) +
  geom_point() + facet_grid(holiday~season)

ggplot(data_pre, aes(x=temp, y=count)) +
  geom_point() + facet_grid(weekend~season)

data_tr
m1 <- lm(
  count ~ season + weather + atemp + humidity + windspeed + poly(hour, 2), 
  data_tr[weather != 'worst', ]
)
par(mfrow = c(2,2))
plot(m1)
m1 %>% summary()
plot(data_tr$hour, data_tr$count)

m2 <- lm(
  count ~ season + weather + atemp * humidity * windspeed + poly(hour, 3),
  data_pre[weather != 'worst', ]
)
plot(data_pre$hour, data_pre$count)

par(mfrow = c(2,2))
plot(m2)
m2 %>% summary()


install.packages(c('rmarkdown', "rsconnect"))


data_pre[weekend == 'yes', ]$casual %>% hist()
data_pre[weekend == 'no', ]$casual %>% hist()

data_pre[weekend == 'yes', ]$registered %>% hist()
data_pre[weekend == 'no', ]$registered %>% hist()

data_pre[weekend == 'yes', ]$count %>% hist()
data_pre[weekend == 'no', ]$count %>% hist()

data_pre


d <- data_pre[weather != 'worst', .(season, weather, atemp, humidity, windspeed)]
d$resid <- m2$residuals

plot(d)


hist(data_pre$casual)
hist(data_pre$registered)
hist(data_pre$count)





ggplot(data_tr, aes(x=humidity, y=count)) +
  geom_point() + facet_grid(weather~season)

ggplot(data_tr, aes(x=humidity, y=count)) +
  geom_point() + facet_grid(holiday~season)

ggplot(data_tr, aes(x=humidity, y=count)) +
  geom_point() + facet_grid(weekend~season)




ggplot(data_tr, aes(x=windspeed, y=count)) +
  geom_point() + facet_grid(weather~season)

ggplot(data_tr, aes(x=windspeed, y=count)) +
  geom_point() + facet_grid(holiday~season)

ggplot(data_tr, aes(x=windspeed, y=count)) +
  geom_point() + facet_grid(weekend~season)

