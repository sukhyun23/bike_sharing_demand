# source ------------------------------------------------------------------
source('./R/data_cleansing.R')

library(mgcv)
library(plotly)
library(reshape2)

dat_tr %>% head

# hour --------------------------------------------------------------------
hour_fit_wend <- gam(
  formula = count ~ s(hour, bs = 'cr', k=6),
  family = poisson(),
  data = dat_weekend
)
# summary(hour_fit_wend)
plot(hour_fit_wend, all.terms = T, pages = 1)
# par(mfrow=c(2,2)); gam.check(hour_fit_wend)

hour_fit_wday <- gam(
  formula = count ~ s(hour, bs = 'cr', k=10),
  family = poisson(),
  data = dat_weekday
)
# summary(hour_fit_wday)
plot(hour_fit_wday, all.terms = T, pages = 1)
# par(mfrow=c(2,2)); gam.check(hour_fit_wday)



# relationship ------------------------------------------------------------
# 1. model
dat_weekend$count_dh <- dat_weekend$count - hour_fit_wend$fitted.values
thi_fit_wend <- gam(
  formula = count_dh ~ s(temp, humidity, k=15), 
  data = dat_weekend
)
summary(thi_fit_wend)
plot(thi_fit_wend, all.terms = T, pages = 1)
par(mfrow=c(2,2)); gam.check(thi_fit_wend)

# 2. surface
temp_seq <- seq(min(dat_weekend$temp), max(dat_weekend$temp), length.out = 30)
hum_seq <- seq(min(dat_weekend$humidity), max(dat_weekend$humidity), length.out = 30)
df <- expand.grid(temp = temp_seq, humidity = hum_seq)
df$fitted <-predict(thi_fit_wend, df)
mat <- reshape2::dcast(
  data = df,
  formula = temp~humidity, 
  value.var = 'fitted'
)
rownames(mat) <- mat[,1]
mat <- as.matrix(mat[,-1])
plot_ly(x = temp_seq, y = hum_seq, z = mat) %>% 
  add_surface() %>% 
  layout(
    scene = list(
      xaxis = list(title = 'temp'), 
      yaxis = list(title = 'humidity'),
      zaxis = list(title = 'count_dh')
    )
  )




# variance structure ------------------------------------------------------
dat_weekend[, sd := sd(count), by = 'hour']


# model -------------------------------------------------------------------
dat_weekend$dtemp <- dat_weekend$temp - dat_weekend$atemp
model <- count ~ s(hour, bs = 'cr', k=6) + 
  s(temp, humidity, k=15) +
  windspeed + season + weather
  # s(windspeed, k=5)
  
weekend_fit <- gam(
  formula = model,
  family = quasipoisson(),
  weights = 1/sd,
  data = dat_weekend
)
summary(weekend_fit)
plot(weekend_fit, all.terms = T, pages = 1)
# par(mfrow=c(2,2)); gam.check(weekend_fit)


plot(dat_weekend$dtemp, dat_weekend$count_dhour)
plot(dat_weekend$dtemp, dat_weekend$count)

ggplot(dat_weekend, aes(dtemp, count_dhour)) +
  geom_point() + geom_smooth(method = 'lm')

ggplot(dat_weekend, aes(abs(dtemp), count_dhour)) +
  geom_point() + geom_smooth()


lm(count_dhour~dtemp, dat_weekend) %>% summary()

plot(sqrt(dat_weekend$windspeed), dat_weekend$count_dhour)

plot(dat_weekend$windspeed, dat_weekend$count)

tapply(dat_weekend$count_dhour, dat_weekend$windspeed != 0, mean)

boxplot(dat_weekend$count_dhour~(dat_weekend$windspeed != 0))

plot(dat_weekend$windspeed, dat_weekend$count_dhour)

# model
# hour : 0~24
# temp : linear? no

dat_weekend$count_without_hour <- round(dat_weekend$count_without_hour - min(dat_weekend$count_without_hour)) + 1


model <- count_without_hour ~ # s(hour, bs = 'cr', k=5) + 
  s(temp, humidity, k=15)

gam_fit <- gam(
  formula = model,
  family = poisson(),
  data = dat_weekend
)
# plot(gam_fit, all.terms = T, pages = 1)
# par(mfrow=c(2,2))
# gam.check(gam_fit)
summary(gam_fit)



  


dat_weekend$count_without_hour <- dat_weekend$count - gam_fit$fitted.values

plot(dat_weekend$temp, dat_weekend$count_without_hour)
plot(dat_weekend$humidity, dat_weekend$count_without_hour)

m <- lm(count_without_hour ~ temp * humidity, dat_weekend)
summary(m)
plot(m)

dat_weekend$temp


# s(humidity, bs = 'cr', k=7) +
  # s(temp, bs = 'cr', k=5) +
  # s(windspeed, bs = 'cr', k=5) + 
  # season + weather





# dat_tmp <- data_tr[weekend == 'no', ]

m <- gam(count ~ s(hour, bs = 'cr', k=20), family = poisson(), data = dat_tmp)
# m %>% summary()
plot(m, residuals = T, pch=19, col=alpha('black', 0.2))

xp <- dat_tmp$hour
fit <- m$fitted.values[order(xp)]
xp <- xp[order(xp)]

plot(dat_tmp$hour, dat_tmp$count, pch=19)
lines(xp, fit, lwd=5, col='red')


dat_tmp <- data_tr[weekend == 'yes', ]
dat_tmp <- data_tr[weekend == 'no', ]
dev.off()
par(mfrow=c(2,2))
for (i in 1:10) {
  m <- gam(count ~ s(hour, bs = 'cr', k=i), family = poisson(), data = dat_tmp)
  xp <- dat_tmp$hour
  fit <- m$fitted.values[order(xp)]
  xp <- xp[order(xp)]
  
  plot(dat_tmp$hour, dat_tmp$count, pch=19, main = i)
  lines(xp, fit, lwd=5, col='red')
}


dat_tmp <- data_tr

dat_tmp <- data_tr[weekend == 'yes', ]
dat_tmp %>% head

mh <- gam(
  formula = count ~ s(hour, bs = 'cr', k=5), 
  family = poisson(), 
  data = dat_tmp
)
mh %>% summary()

m1 <- gam(
  formula = count ~ s(hour, bs = 'cr', k=5) +
    s(humidity, bs = 'cr', k=3) +
    s(temp, bs = 'cr', k=5) +
    windspeed + season * weather
  ,
  family = poisson(), 
  data = dat_tmp
)
m1 %>% summary()
dev.off()
par(mfrow=c(3,2))
plot(m1, all.terms = T, pch=19) # residuals = T



dat_tmp %>% head
count_decomp <- dat_tmp$count - mh$fitted.values
x <- dat_tmp$temp
cor(x, count_decomp)
gdat <- data.table(x=x, y=count_decomp)
ggplot(gdat, aes(x=x, y=y)) + 
  geom_point() +
  geom_smooth()




pr <- prcomp(scale(dat_tmp[, .(temp, temp - atemp, humidity, windspeed)]))
pr %>% summary()
plot(pr$x[,1], pr$x[,2])

par(mfrow=c(1,1))
biplot(pr)
# method = 'lm'

plot(dat_tmp$temp, dat_tmp$atemp)
xt <- dat_tmp$temp - dat_tmp$atemp
rp <- rpart(count_decomp ~ xt)
rpart.plot(rp)

library(rpart.plot)


d <- scale(dat_tmp[, .(temp, temp - atemp, humidity, windspeed)])
mt <- lm(count_decomp ~ d)
summary(mt)
plot(mt)


dat_tmp$decomp_count <- dat_tmp$count - mh$fitted.values
dat_tmp$diff_temp <- dat_tmp$temp - dat_tmp$atemp
m <- lm(
  # decomp_count ~ temp + diff_temp + humidity + windspeed + season + weather, 
  decomp_count ~ temp * humidity, # 
  dat_tmp
)
summary(m)
par(mfrow = c(2,2))
plot(m)

dat_tmp %>% head

boxplot(dat_tmp$temp ~ dat_tmp$weather)
boxplot(dat_tmp$temp ~ dat_tmp$season)


dat_tmp[, .(temp, humidity, windspeed, diff_temp, decomp_count)] %>% plot


m0 <- lm(decomp_count ~ 1, dat_tmp)
mf <- lm(decomp_count ~ temp + humidity * windspeed * diff_temp, dat_tmp)
s <- step(m0, scope = list(upper = mf))
summary(s)



tapply(dat_tmp$decomp_count, list(dat_tmp$weather, dat_tmp$season), mean)
tapply(dat_tmp$count, list(dat_tmp$weather, dat_tmp$season), mean)


aov(decomp_count ~ weather * season, dat_tmp) %>% summary()

ggplot(dat_tmp) +
  geom_boxplot(aes(x=season, y=count)) +
  facet_grid(.~weather)


rp <- rpart(decomp_count ~ weather + season, dat_tmp)
rpart.plot(rp)


mm <- lm(decomp_count ~ weather * season, dat_tmp) 
mm %>% summary()

dev.off()
boxplot(decomp_count ~ season, dat_tmp)
boxplot(decomp_count ~ weather, dat_tmp)

ggplot(dat_tmp) +
  geom_boxplot(aes(x=season, y=decomp_count)) +
  facet_grid(.~weather)





m1 <- gam(
  formula = count ~ s(hour, bs = 'cr', k=5) +
    s(humidity, bs = 'cr', k=3) +
    s(temp, bs = 'cr', k=5) +
    windspeed + season * weather
  ,
  family = poisson(), 
  data = dat_tmp
)
m1 %>% summary()



cv_gam <- function(form, data_tmp, idx_list, link) {
  model_mse <- c(); model_rsq <- c()
  for (i in 1:10) {
    m1 <- gam(
      formula = form,
      family = link, 
      data = dat_tmp[-idx_list[[i]], ]
    )
    
    model_mse[i] <- Metrics::mse(dat_tmp[-idx_list[[i]], ]$count, m1$fitted.values)
    model_rsq[i] <- cor(dat_tmp[-idx_list[[i]], ]$count, m1$fitted.values)^2
  }  
  return(list(model_mse, model_rsq))
}

dat_tmp <- data_tr[weekend == 'yes', ]
dat_tmp$diff_temp <- dat_tmp$temp - dat_tmp$atemp
idx_list <- createFolds(dat_tmp$count, k = 10)
form1 <- count ~ s(hour, bs = 'cr', k=5) +
  s(humidity, bs = 'cr', k=3) +
  s(temp, bs = 'cr', k=5) +
  windspeed + season + weather

form2 <- count ~ s(hour, bs = 'cr', k=5) +
  s(humidity, bs = 'cr', k=3) +
  s(temp, bs = 'cr', k=5) +
  windspeed + season + weather

result1 <- cv_gam(form1, dat_tmp, idx_list)
result2 <- cv_gam(form2, dat_tmp, idx_list)

lapply(result1, mean)
lapply(result2, mean)





dat_tmp <- data_tr[weekend == 'no', ]
idx_list <- createFolds(dat_tmp$count, k = 10)
form <- count ~ s(hour, bs = 'cr', k=10) +
  s(humidity, bs = 'cr', k=5) +
  s(temp, bs = 'cr', k=2) +
  windspeed + season + weather
  
m1 <- gam(
  formula = form,
  # family = poisson(link = 'log'),
  family = Gamma(link = 'log'), 
  data = dat_tmp
)
par(mfrow=c(3,3))
summary(m1)
plot(m1)


par(mfrow=c(2,2))
gam.check(m1)



dat_tmp <- data_tr[weekend == 'yes', ]
idx_list <- createFolds(dat_tmp$count, k = 10)
form <- count ~ 
  s(hour, bs = 'cr', k=5) +
  s(humidity, bs = 'cr', k=7) +
  s(temp, bs = 'cr', k=5) +
  s(windspeed, bs = 'cr', k=5) + 
  season + weather

dat_tmp[, w := sd(count), by='hour']

now_form <-count ~ s(hour, bs = 'cr', k=5)
no_w <- gam(
  formula = now_form,
  family = poisson(),
  data = dat_tmp
)
plot(no_w)
gam.check(no_w)
dat_tmp$u <- no_w$residuals
w <- gam(
  formula = update(now_form, I(log(u^2)) ~ .),
  data = dat_tmp
)
dat_tmp$h <- exp(w$fitted.values)
plot(dat_tmp$hour, dat_tmp$h)

dat_tmp$date
m1 <- gam(
  formula = form,
  family = quasipoisson(),
  # family = poisson(link = 'log'),
  weights = h,
  # family = negbin(theta = 3.5), 
  # family = Gamma(link = 'log'),
  data = dat_tmp
)
summary(m1)
par(mfrow=c(2,2))
gam.check(m1)
plot(m1, pages=1)


plot(dat_tmp$windspeed, m1$residuals)

hist(dat_tmp$windspeed)
log(dat_tmp$windspeed+1)



par(mfrow=c(3,3))

plot(m1)


obs_counts <- table(dat_tmp$count)[1:100]
exp_probs <- sapply(1:100, function(x) dpois(x, m1$fitted.values))
exp_counts <- round(apply(exp_probs, 2, sum))

# table
# rbind(obs_counts, exp_counts)
# plot
plot(1:100, obs_counts, pch = 19, col = 'red', xlab = 'count')
lines(1:100, obs_counts, col = 'red')
points(1:100, exp_counts, pch = 19, col = 'blue')
lines(1:100, exp_counts, col = 'blue')
legend('topright', c('obs', 'exp'), pch=19, col=c('red', 'blue'))


plot(dat_tmp$humidity, dat_tmp$count)


m <- lm(count~hour, dat_tmp)
plot(dat_tmp$hour, m$residuals)
e <- m$residuals - min(m$residuals) + 1
plot(dat_tmp$hour, e)

plot(1/tapply(dat_tmp$count, dat_tmp$hour, sd))

tapply(dat_tmp$count, dat_tmp$hour, sd)


plot(m)


link1 = poisson(link = 'log')
link2 = negbin(theta = 3.5)
link2 = Gamma(link = 'log')
link2 = identity()
result1 <- cv_gam(form, dat_tmp, idx_list, link = link1)
result2 <- cv_gam(form, dat_tmp, idx_list, link = link2)

result1
result2


mean(m1$fitted.values)
var(m1$fitted.values)

mean(dat_tmp$count)
var(dat_tmp$count)


glm()

