# source ------------------------------------------------------------------
source('./R/data_cleansing.R')
source('./R/functions.R')
library(mgcv)
library(plotly)
library(reshape2)



# modeled data ------------------------------------------------------------
y <- 'registered' # 'casual', 'registered'
dat_sub <- dat_tr[weekend == 'yes', ] # 'yes', 'no'
# dat_sub <- dat_tr
dat_sub[, sd := sd(count), by = 'hour']



# hour --------------------------------------------------------------------
model <- as.formula(paste(y, ' ~ 1'))
hour_fit <- gam(
  formula = update(model, . ~ s(hour, bs = 'cr', k=11)),
  family = quasipoisson(),
  weights = 1/sd,
  data = dat_sub
)
summary(hour_fit)
plot(hour_fit, all.terms = T, pages = 1)
par(mfrow=c(2,2)); gam.check(hour_fit)



# inference ---------------------------------------------------------------
# 1. model
dat_sub$y_dh <- dat_sub[[y]] - hour_fit$fitted.values
thi_fit <- gam(
  formula = y_dh ~ s(temp, humidity, k=20), # + s(temp, windspeed, k=10),
  data = dat_sub
)
summary(thi_fit)
plot(thi_fit, all.terms = T, pages = 1)
par(mfrow=c(2,2)); gam.check(thi_fit)
thi_fit$fitted.values %>% summary()

# 2. surface
tpa::surface(object = thi_fit, c('temp', 'humidity'))



# modeling ----------------------------------------------------------------
model <- as.formula(paste(y, ' ~ 1'))
model <- update(
  model, . ~ s(hour, k=11) + 
    s(temp, humidity, k=8) + 
    s(temp, windspeed, k=9) +
    season2 + weather2 + weekend
)
gam_fit <- gam(
  formula = model,
  family = quasipoisson(),
  # weights = 1/sd,
  data = dat_sub
)
summary(gam_fit)
plot(gam_fit, pages = 1, all.terms = T)
gam.check(gam_fit)


# surface plot
tpa::surface(gam_fit, view = c('temp', 'humidity'))
tpa::surface(gam_fit, view = c('temp', 'windspeed'))

# 10 fold cv error
idx_cv <- caret::createFolds(dat_sub[[y]], k = 10)
metric_list <- list()
for (i in idx_cv) {
  cv_train <- dat_sub[-i,]
  cv_test <- dat_sub[i,]

  cv_fit <- gam(
    formula = model, family = quasipoisson(), 
    weights = 1/sd, data = cv_train
  )
  cv_pred <- round(exp(predict(cv_fit, cv_test)))

  metric <- c(
    rsq = cor(cv_test[[y]], cv_pred)^2,
    log_rsq = cor(log(cv_test[[y]]+1), log(cv_pred+1))^2,
    rmse = Metrics::rmse(cv_test[[y]], cv_pred),
    rmsle = Metrics::rmsle(cv_test[[y]], cv_pred)
  )
  metric_list <- append(metric_list, list(metric))
}
t(apply(sapply(metric_list, function(x) x), 1, tpa::summary2))


# model save
# saveRDS(gam_fit, './model/regit_end.rds')
# saveRDS(gam_fit, './model/regit_day.rds')
# saveRDS(gam_fit, './model/casual.rds')



# model info --------------------------------------------------------------
# registered weekend 
model <- as.formula(paste(y, ' ~ 1'))
model <- update(
  model, . ~ s(hour, k=14) + 
    s(temp, humidity, k=10) +
    s(temp, windspeed, k=12) + 
    season2 + weather2
)

# registered weekday
model <- as.formula(paste(y, ' ~ 1'))
model <- update(
  model, . ~ s(hour, k=12) + 
    s(temp, humidity, k=7) + 
    s(temp, windspeed, k=9) + 
    season2 + weather2
)

# casual
model <- as.formula(paste(y, ' ~ 1'))
model <- update(
  model, . ~ s(hour, k=11) + 
    s(temp, humidity, k=8) + 
    s(temp, windspeed, k=9) +
    season2 + weather2 + weekend
)




model <- as.formula(paste(y, ' ~ 1'))
model <- update(
  model, . ~ s(hour, k=14) + 
    s(temp, humidity, k=10) +
    s(temp, windspeed, k=12) + 
    season2 + weather2
)
noweighted <- gam(
  formula = model,
  family = quasipoisson(),
  data = dat_sub
)
weighted <- gam(
  formula = model,
  family = quasipoisson(),
  weights = 1/sd,
  data = dat_sub
)

par(mfrow = c(1,2))
gam.check(noweighted)


plot(noweighted$linear.predictors, resid(noweighted))
plot(weighted$linear.predictors, resid(weighted))

