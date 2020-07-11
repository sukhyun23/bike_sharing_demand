# source ------------------------------------------------------------------
source('./R/data_cleansing.R')
source('./R/functions.R')

# y -----------------------------------------------------------------------
nrow(dat_tr)
sum((dat_tr$casual + dat_tr$registered) == dat_tr$count)

par(mfrow = c(1,3))
for (i in c('casual', 'registered', 'count')) {
  m <- round(mean(dat_tr[[i]]))
  v <- round(var(dat_tr[[i]]))
  m <- paste('mean :', m)
  v <- paste('var :', v)
  hist(
    dat_tr[[i]], ylim = c(0,6000), xlim = c(0, 1000), main = title(c(i,m,v)),
    xlab = ''
  )
}


# date of train, test -----------------------------------------------------
train_date <- tapply(
  dat_tr$date, 
  list(dat_tr$year, dat_tr$month), 
  function(x) paste(c(min(x), max(x)), collapse = '~')
)
test_date <- tapply(
  dat_te$date, 
  list(dat_te$year, dat_te$month), 
  function(x) paste(c(min(x), max(x)), collapse = '~')
)
# train : 1 ~ 19
# test : 19 ~ end of month
for (i in 1:length(train_date)) {
  if (i == 1) cat('train                  |  test\n')
  cat(c(train_date[[i]],' | ', test_date[[i]], '\n'))
}

# barplot year
bar_data <- dat_tr[, .(count=mean(count)), by=c('year', 'month')]
bar_data$year <- as.character(bar_data$year)
ggplot(bar_data, aes(x=month, y=count, fill=year)) +
  geom_bar(stat='identity', position='dodge') + 
  scale_x_continuous(breaks=bar_data$month) + 
  scale_fill_manual(values=c('skyblue', 'dodgerblue3'))

# boxplot season1
ggplot(dat_tr) + 
  geom_boxplot(aes(y=count, fill=season)) + 
  facet_grid(~ season + holiday) +
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4'))

# boxplot season2
ggplot(dat_tr) + 
  geom_boxplot(aes(y=count, fill=season)) + 
  facet_grid(~ season + workingday) +
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4'))

# boxplot season3
ggplot(dat_tr) + 
  geom_boxplot(aes(y=count, fill=season)) + 
  facet_grid(~ season + weather) +
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4'))

# boxplot weather1
ggplot(dat_tr) + 
  geom_boxplot(aes(y=count, fill=weather)) + 
  facet_grid(~ weather + holiday) +
  scale_fill_manual(values=c('grey90', 'grey60', 'grey35', 'black'))

# boxplot weather2
ggplot(dat_tr) + 
  geom_boxplot(aes(y=count, fill=weather)) + 
  facet_grid(~ weather + workingday) +
  scale_fill_manual(values=c('grey90', 'grey60', 'grey35', 'black'))



# time series -------------------------------------------------------------
par(mfrow = c(1,3))
for (i in c('casual', 'registered', 'count')) {
  plot(
    dat_tr$datetime, dat_tr[[i]], xlab = 'datetime', ylab = '', main = i
  )
}

# profile by day
par(mfrow = c(1,1))
plot(dat_tr$hour, dat_tr$count, 'n', xlab = 'hour', ylab = 'count')
by(dat_tr, dat_tr$date, function(d) lines(d$hour, d$count, col=alpha(1, 0.3)))

day_profile_plot(dat_tr, 'season', 'count', c(2,2))
day_profile_plot(dat_tr, 'holiday', 'count', c(1,2))
day_profile_plot(dat_tr, 'workingday', 'count', c(1,2))
day_profile_plot(dat_tr, 'weekdays', 'count', c(2,4))
day_profile_plot(dat_tr, 'weather', 'count', c(2,2))
day_profile_plot(dat_tr, 'weekend', 'count', c(1,2)) #########

day_profile_plot(dat_tr, 'season', 'registered', c(2,2))
day_profile_plot(dat_tr, 'holiday', 'registered', c(1,2))
day_profile_plot(dat_tr, 'workingday', 'registered', c(1,2))
day_profile_plot(dat_tr, 'weekdays', 'registered', c(2,4))
day_profile_plot(dat_tr, 'weather', 'registered', c(2,2))
day_profile_plot(dat_tr, 'weekend', 'registered', c(1,2)) #########

day_profile_plot(dat_tr, 'season', 'casual', c(2,2))
day_profile_plot(dat_tr, 'holiday', 'casual', c(1,2))
day_profile_plot(dat_tr, 'workingday', 'casual', c(1,2))
day_profile_plot(dat_tr, 'weekdays', 'casual', c(2,4))
day_profile_plot(dat_tr, 'weather', 'casual', c(2,2))
day_profile_plot(dat_tr, 'weekend', 'casual', c(1,2)) #########



# scatter plot
ggplot(dat_tr, aes(x=temp, y=count)) +
  geom_point() + facet_grid(weather~season)

ggplot(dat_tr, aes(x=temp, y=count)) +
  geom_point() + facet_grid(holiday~season)

ggplot(dat_tr, aes(x=temp, y=count)) +
  geom_point() + facet_grid(weekend~season)

ggplot(dat_tr, aes(x=humidity, y=count)) +
  geom_point() + facet_grid(weather~season)

ggplot(dat_tr, aes(x=humidity, y=count)) +
  geom_point() + facet_grid(holiday~season)

ggplot(dat_tr, aes(x=humidity, y=count)) +
  geom_point() + facet_grid(weekend~season)

ggplot(dat_tr, aes(x=windspeed, y=count)) +
  geom_point() + facet_grid(weather~season)

ggplot(dat_tr, aes(x=windspeed, y=count)) +
  geom_point() + facet_grid(holiday~season)

ggplot(dat_tr, aes(x=windspeed, y=count)) +
  geom_point() + facet_grid(weekend~season)


# cross table
table(dat_tr$season, dat_tr$holiday)
table(dat_tr$season, dat_tr$weekdays)
table(dat_tr$season, dat_tr$weekend)
table(dat_tr$season, dat_tr$workingday)
table(dat_tr$season, dat_tr$weather)
