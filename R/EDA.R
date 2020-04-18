# source ------------------------------------------------------------------
source('./R/data_cleansing.R')


# y -----------------------------------------------------------------------
nrow(data_tr)
sum((data_tr$casual + data_tr$registered) == data_tr$count)

par(mfrow = c(1,3))
for (i in c('casual', 'registered', 'count')) {
  hist(data_tr[[i]], ylim = c(0,6000), xlim = c(0, 1000), main = i)
}

c(mean(data_tr$casual), var(data_tr$casual))
c(mean(data_tr$registered), var(data_tr$registered))
c(mean(data_tr$count), var(data_tr$count))



# date of train, test -----------------------------------------------------
train_date <- tapply(
  data_tr$date, 
  list(data_tr$year, data_tr$month), 
  function(x) paste(c(min(x), max(x)), collapse = '~')
)
test_date <- tapply(
  data_te$date, 
  list(data_te$year, data_te$month), 
  function(x) paste(c(min(x), max(x)), collapse = '~')
)
# train : 1 ~ 19
# test : 19 ~ end of month
for (i in 1:length(train_date)) {
  if (i == 1) cat('train                  |  test\n')
  cat(c(train_date[[i]],' | ', test_date[[i]], '\n'))
}

# barplot year
bar_data <- data_tr[, .(count=mean(count)), by=c('year', 'month')]
bar_data$year <- as.character(bar_data$year)
ggplot(bar_data, aes(x=month, y=count, fill=year)) +
  geom_bar(stat='identity', position='dodge') + 
  scale_x_continuous(breaks=bar_data$month) + 
  scale_fill_manual(values=c('skyblue', 'dodgerblue3'))

# boxplot season1
ggplot(data_tr) + 
  geom_boxplot(aes(y=count, fill=season)) + 
  facet_grid(~ season + holiday) +
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4'))

# boxplot season2
ggplot(data_tr) + 
  geom_boxplot(aes(y=count, fill=season)) + 
  facet_grid(~ season + workingday) +
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4'))

# boxplot season3
ggplot(data_tr) + 
  geom_boxplot(aes(y=count, fill=season)) + 
  facet_grid(~ season + weather) +
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4'))

# boxplot weather1
ggplot(data_tr) + 
  geom_boxplot(aes(y=count, fill=weather)) + 
  facet_grid(~ weather + holiday) +
  scale_fill_manual(values=c('grey90', 'grey60', 'grey35', 'black'))

# boxplot weather2
ggplot(data_tr) + 
  geom_boxplot(aes(y=count, fill=weather)) + 
  facet_grid(~ weather + workingday) +
  scale_fill_manual(values=c('grey90', 'grey60', 'grey35', 'black'))



# time series -------------------------------------------------------------
par(mfrow = c(1,3))
plot(data_tr$datetime, data_tr$casual)
plot(data_tr$datetime, data_tr$registered)
plot(data_tr$datetime, data_tr$count)

# profile by day
par(mfrow = c(1,1))
plot(data_tr$hour, data_tr$count, 'n')
by(data_tr, data_tr$date, function(d) lines(d$hour, d$count))

# data <- data_tr
profile_hour <- function(data, figsize = c(1,2), group, y) {
  par(mfrow = figsize)
  for (i in unique(data[[group]])) {
    plot(
      data$hour, data[[y]], 'n',
      main = paste(group, i, sep = ' : '),
      xlab = 'hour', ylab = 'count'
    )
    by(
      data[data[[group]] == i],
      data[data[[group]] == i]$date,
      function(d) lines(d$hour, d[[y]])
    )    
  }
  invisible(NULL)
}
profile_hour(data_tr, c(2,2), 'season', 'count')
profile_hour(data_tr, c(1,2), 'holiday', 'count')
profile_hour(data_tr, c(1,2), 'workingday', 'count')
profile_hour(data_tr, c(2,4), 'weekdays', 'count')
profile_hour(data_tr, c(2,2), 'weather', 'count')
profile_hour(data_tr, c(1,2), 'weekend', 'count')

profile_hour(data_tr, c(2,2), 'season', 'registered')
profile_hour(data_tr, c(1,2), 'holiday', 'registered')
profile_hour(data_tr, c(1,2), 'workingday', 'registered')
profile_hour(data_tr, c(2,4), 'weekdays', 'registered')
profile_hour(data_tr, c(2,2), 'weather', 'registered')
profile_hour(data_tr, c(1,2), 'weekend', 'registered')

profile_hour(data_tr, c(2,2), 'season', 'casual')
profile_hour(data_tr, c(1,2), 'holiday', 'casual')
profile_hour(data_tr, c(1,2), 'workingday', 'casual')
profile_hour(data_tr, c(2,4), 'weekdays', 'casual')
profile_hour(data_tr, c(2,2), 'weather', 'casual')
profile_hour(data_tr, c(1,2), 'weekend', 'casual')

dev.off()
profile_hour(data_tr, c(1,2), 'weekend', 'casual')
profile_hour(data_tr, c(1,2), 'weekend', 'registered')
profile_hour(data_tr, c(1,2), 'weekend', 'count')




#
ggplot(data_tr, aes(x=temp, y=count)) +
  geom_point() + facet_grid(weather~season)

ggplot(data_tr, aes(x=temp, y=count)) +
  geom_point() + facet_grid(holiday~season)

ggplot(data_tr, aes(x=temp, y=count)) +
  geom_point() + facet_grid(weekend~season)



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




table(data_tr$season, data_tr$holiday)
table(data_tr$season, data_tr$weekdays)
table(data_tr$season, data_tr$weekend)
table(data_tr$season, data_tr$workingday)
table(data_tr$season, data_tr$weather)


