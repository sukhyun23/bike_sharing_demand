# libs --------------------------------------------------------------------
library(lubridate)
library(data.table)
library(ggplot2)
library(dplyr)

data_tr <- fread('/home/sukhyun/dataset/bike_sharing_demand/train.csv')
data_te <- fread('/home/sukhyun/dataset/bike_sharing_demand/test.csv')


# data cleansing ----------------------------------------------------------
# variables
data_te$casual <- NA
data_te$registered <- NA
data_te$count <- NA

# time
data_tr$datetime <- data_tr$datetime %>% as.POSIXct()
data_te$datetime <- data_te$datetime %>% as.POSIXct()

data_tr <- data_tr[order(datetime), ]
data_te <- data_te[order(datetime), ]

# season
data_tr$season <- factor(
  data_tr$season, labels = c('spring', 'summer', 'fall', 'winter')
)
data_te$season <- factor(
  data_te$season, labels = c('spring', 'summer', 'fall', 'winter')
)

# holiday 
# whether the day is considered a holiday
data_tr$holiday <- factor(data_tr$holiday, labels = c('no', 'yes'))
data_te$holiday <- factor(data_te$holiday, labels = c('no', 'yes'))

# workingday 
# whether the day is neither a weekend nor holiday
data_tr$workingday <- factor(data_tr$workingday, labels = c('no', 'yes'))
data_te$workingday <- factor(data_te$workingday, labels = c('no', 'yes'))

# weather 
# 1: Clear, Few clouds, Partly cloudy, Partly cloudy
# 2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist
# 3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds
# 4: Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog 
data_tr$weather <- factor(
  data_tr$weather, labels = c('best', 'better', 'worse', 'worst')
)
data_te$weather <- factor(
  data_te$weather, labels = c('best', 'better', 'worse', 'worst')
)

# date
data_tr$date <- as.Date(data_tr$datetime)
data_te$date <- as.Date(data_te$datetime)

# hour
data_tr$hour <- hour(data_tr$datetime)
data_te$hour <- hour(data_te$datetime)

# weekdays
data_tr$weekdays <- tolower(weekdays(data_tr$datetime))
data_te$weekdays <- tolower(weekdays(data_te$datetime))

# weekend
data_tr$weekend <- ifelse(
  data_tr$weekdays %in% c('saturday', 'sunday'), 'yes', 'no'
)
data_te$weekend <- ifelse(
  data_te$weekdays %in% c('saturday', 'sunday'), 'yes', 'no'
)

# month
data_tr$month <- month(data_tr$date)
data_te$month <- month(data_te$date)

# year
data_tr$year <- year(data_tr$date)
data_te$year <- year(data_te$date)

# order
var_order <- c(
  'date', 'year', 'month', 'hour', 'datetime', 'season', 'holiday',
  'weekdays', 'weekend', 'workingday', 'weather', 'temp', 'atemp',
  'humidity', 'windspeed', 'casual', 'registered', 'count'
)

data_tr <- data_tr[, var_order, with = F]
data_te <- data_te[, var_order, with = F]
rm(var_order)

data <- rbind(data_tr, data_te)
