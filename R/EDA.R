# source ------------------------------------------------------------------
source('./R/data_cleansing.R')


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

# data <- dat_tr 
# figsize <- c(1,2)
# group <- 'weekend'
# y <- 'count'
profile_hour <- function(data, figsize = c(1,2), group, y) {
  par(mfrow = figsize)
  for (i in unique(data[[group]])) {
    plot(
      data$hour, data[[y]], 'n',
      main = paste(group, i, sep = ' : '),
      xlab = 'hour', ylab = 'count', xaxt='n'
    )
    axis(1, 0:23)
    by(
      data[data[[group]] == i],
      data[data[[group]] == i]$date,
      function(d) lines(d$hour, d[[y]], col=alpha(1, 0.3))
    ) 
    means <- tapply(
      data[data[[group]] == i]$count,
      data[data[[group]] == i]$hour,
      mean
    )
    lines(0:23, means, lwd=5, col='dodgerblue1')
  }
  invisible(NULL)
}
profile_hour(dat_tr, c(2,2), 'season', 'count')
profile_hour(dat_tr, c(1,2), 'holiday', 'count')
profile_hour(dat_tr, c(1,2), 'workingday', 'count')
profile_hour(dat_tr, c(2,4), 'weekdays', 'count')
profile_hour(dat_tr, c(2,2), 'weather', 'count')
profile_hour(dat_tr, c(1,2), 'weekend', 'count')

profile_hour(dat_tr, c(2,2), 'season', 'registered')
profile_hour(dat_tr, c(1,2), 'holiday', 'registered')
profile_hour(dat_tr, c(1,2), 'workingday', 'registered')
profile_hour(dat_tr, c(2,4), 'weekdays', 'registered')
profile_hour(dat_tr, c(2,2), 'weather', 'registered')
profile_hour(dat_tr, c(1,2), 'weekend', 'registered')

profile_hour(dat_tr, c(2,2), 'season', 'casual')
profile_hour(dat_tr, c(1,2), 'holiday', 'casual')
profile_hour(dat_tr, c(1,2), 'workingday', 'casual')
profile_hour(dat_tr, c(2,4), 'weekdays', 'casual')
profile_hour(dat_tr, c(2,2), 'weather', 'casual')
profile_hour(dat_tr, c(1,2), 'weekend', 'casual')

dev.off()
profile_hour(dat_tr, c(1,2), 'weekend', 'casual')
profile_hour(dat_tr, c(1,2), 'weekend', 'registered')
profile_hour(dat_tr, c(1,2), 'weekend', 'count')


profile_hour(data_pre, c(1,2), 'weekend', 'casual')
profile_hour(data_pre, c(1,2), 'weekend', 'registered')
profile_hour(data_pre, c(1,2), 'weekend', 'count')




#
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




table(dat_tr$season, dat_tr$holiday)
table(dat_tr$season, dat_tr$weekdays)
table(dat_tr$season, dat_tr$weekend)
table(dat_tr$season, dat_tr$workingday)
table(dat_tr$season, dat_tr$weather)


