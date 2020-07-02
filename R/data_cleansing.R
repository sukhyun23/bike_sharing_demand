# libs --------------------------------------------------------------------
library(lubridate)
library(data.table)
library(ggplot2)
library(dplyr)

dat_tr <- fread('/home/sukhyun/dataset/bike_sharing_demand/train.csv')
dat_te <- fread('/home/sukhyun/dataset/bike_sharing_demand/test.csv')


# data cleansing ----------------------------------------------------------
# variables
dat_te$casual <- NA
dat_te$registered <- NA
dat_te$count <- NA

# time
dat_tr$datetime <- dat_tr$datetime %>% as.POSIXct()
dat_te$datetime <- dat_te$datetime %>% as.POSIXct()

dat_tr <- dat_tr[order(datetime), ]
dat_te <- dat_te[order(datetime), ]

# season
dat_tr$season <- factor(
  dat_tr$season, labels = c('spring', 'summer', 'fall', 'winter')
)
dat_te$season <- factor(
  dat_te$season, labels = c('spring', 'summer', 'fall', 'winter')
)

# holiday 
# whether the day is considered a holiday
dat_tr$holiday <- factor(dat_tr$holiday, labels = c('no', 'yes'))
dat_te$holiday <- factor(dat_te$holiday, labels = c('no', 'yes'))

# workingday 
# whether the day is neither a weekend nor holiday
dat_tr$workingday <- factor(dat_tr$workingday, labels = c('no', 'yes'))
dat_te$workingday <- factor(dat_te$workingday, labels = c('no', 'yes'))

# weather 
# 1: Clear, Few clouds, Partly cloudy, Partly cloudy
# 2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist
# 3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds
# 4: Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog 
dat_tr$weather <- factor(
  dat_tr$weather, labels = c('best', 'better', 'worse', 'worst')
)
dat_te$weather <- factor(
  dat_te$weather, labels = c('best', 'better', 'worse', 'worst')
)
# remove worst
dat_tr <- dat_tr[!weather == 'worst', ]
dat_te <- dat_te[!weather == 'worst', ]


# date
dat_tr$date <- as.Date(dat_tr$datetime)
dat_te$date <- as.Date(dat_te$datetime)

# hour
dat_tr$hour <- hour(dat_tr$datetime)
dat_te$hour <- hour(dat_te$datetime)

# weekdays
dat_tr$weekdays <- tolower(weekdays(dat_tr$datetime))
dat_te$weekdays <- tolower(weekdays(dat_te$datetime))

# weekend
dat_tr$weekend <- ifelse(
  dat_tr$weekdays %in% c('saturday', 'sunday'), 'yes', 'no'
)
dat_te$weekend <- ifelse(
  dat_te$weekdays %in% c('saturday', 'sunday'), 'yes', 'no'
)

# month
dat_tr$month <- month(dat_tr$date)
dat_te$month <- month(dat_te$date)

# year
dat_tr$year <- year(dat_tr$date)
dat_te$year <- year(dat_te$date)

# order
var_order <- c(
  'date', 'year', 'month', 'hour', 'datetime', 'season', 'holiday',
  'weekdays', 'weekend', 'workingday', 'weather', 'temp', 'atemp',
  'humidity', 'windspeed', 'casual', 'registered', 'count'
)

dat_tr <- dat_tr[, var_order, with = F]
dat_te <- dat_te[, var_order, with = F]
rm(var_order)

dat <- rbind(dat_tr, dat_te)
dat_weekend <- dat_tr[weekend == 'yes', ]
dat_weekday <- dat_tr[weekend == 'no', ]