# source ------------------------------------------------------------------
source('./R/data_cleansing.R')

head(data_tr)
poi <- glm(
  count~season+holiday+temp+humidity+windspeed+hour+I(hour^2),
  data = data_tr, family = poisson
)
summary(poi)



obs_freq <- table(data_tr$count)[1:50]
count_unique <- names(obs_freq) %>% as.integer()

exp_prob <- sapply(count_unique, function(x) dpois(x, lambda = poi$fitted.values))
exp_freq <- round(apply(exp_prob, 2, sum))
exp_freq

plot(count_unique, obs_freq, col='red', pch=19, ylim = c(0,250))
lines(count_unique, obs_freq, col='red')
points(count_unique, exp_freq, col='blue', pch=19)
lines(count_unique, exp_freq, col='blue')



data_tr[, .(mean(casual), var(casual)), by='season']
data_tr[, .(mean(registered), var(registered)), by='season']
data_tr[, .(mean(count), var(count)), by='season']

data_tr[, .(mean(casual), var(casual)), by='hour']
data_tr[, .(mean(registered), var(registered)), by='hour']
data_tr[, .(mean(count), var(count)), by='hour']

data_tr[, .(mean(casual), var(casual), .N), by=c('hour', 'month', 'weekend')]
data_tr[, .(mean(registered), var(registered), .N), by=c('hour', 'month', 'weekend')]
data_tr[, .(mean(count), var(count), .N), by=c('hour', 'month', 'weekend')]

data_tr %>% head()


