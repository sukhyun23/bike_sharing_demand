# source ------------------------------------------------------------------
source('./R/data_cleansing.R')
source('./R/functions.R')
library(mgcv)
library(plotly)
library(reshape2)

regit_end <- readRDS("./model/regit_end.rds")
regit_day <- readRDS("./model/regit_day.rds")
casual <- readRDS("./model/casual.rds")


y <- 'registered' # 'casual', 'registered'
dat_sub <- dat_tr[weekend == 'yes', ] # 'yes', 'no'
dat_sub[, sd := sd(count), by = 'hour']
model <- as.formula(paste(y, ' ~ 1'))
model <- update(
  model, . ~ s(hour, k=14) + 
    s(temp, humidity, k=16) +
    s(temp, windspeed, k=12) + 
    season2 + weather2
)
regit_end <- gam(
  formula = model,
  family = quasipoisson(),
  weights = 1/sd,
  data = dat_sub
)
surface(regit_end, c('temp', 'humidity'))



# interpretation ----------------------------------------------------------
plot(regit_end, pages = 1, all.terms = T)
surface(regit_end, c('temp', 'humidity'), type = 'response')
surface(regit_end, c('temp', 'windspeed'), type = 'response')
surface(regit_end, c('humidity', 'windspeed'), type = 'response')

plot(regit_day, pages = 1, all.terms = T)
surface(regit_day, c('temp', 'humidity'), type = 'response')
surface(regit_day, c('temp', 'windspeed'), type = 'response')
surface(regit_day, c('humidity', 'windspeed'), type = 'response')

plot(casual, pages = 1, all.terms = T)
surface(casual, c('temp', 'humidity'), type = 'response')
surface(casual, c('temp', 'windspeed'), type = 'response')
surface(casual, c('humidity', 'windspeed'), type = 'response')


# prediction --------------------------------------------------------------
pred_regit_end <- predict(regit_end, dat_te[weekend=='yes', ])
pred_regit_day <- predict(regit_day, dat_te[weekend=='no', ])
pred_casual <- predict(casual, dat_te)

pred_regit <- rep(NA, nrow(dat_te))
pred_regit[dat_te$weekend == 'yes'] <- pred_regit_end
pred_regit[dat_te$weekend == 'no'] <- pred_regit_day

dat_te$registered <- exp(pred_regit)
dat_te$casual <- exp(pred_casual)
dat_te$count <- exp(pred_regit) + exp(pred_casual)

day_profile_plot(dat_te, 'weekend', 'registered', c(1,2))
day_profile_plot(dat_tr, 'weekend', 'registered', c(1,2))

day_profile_plot(dat_te, 'weekend', 'casual', c(1,2))
day_profile_plot(dat_tr, 'weekend', 'casual', c(1,2))

day_profile_plot(dat_te, 'weekend', 'count', c(1,2))
day_profile_plot(dat_tr, 'weekend', 'count', c(1,2))

# file to submit
pred_sub <- dat_te[, .(datetime, count)]
pred_sub$datetime <- pred_sub$datetime %>% as.character()
pred_sub$count <- round(pred_sub$count)
fwrite(
  pred_sub,
  "/home/sukhyun/project/bike_sharing_demand/model/prediction.csv"
)
# scp sukhyun@211.216.113.172:/home/sukhyun/project/bike_sharing_demand/model/prediction.csv C:\Users\shkwo
