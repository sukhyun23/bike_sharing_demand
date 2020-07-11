# source ------------------------------------------------------------------
source('./R/data_cleansing.R')
source('./R/functions.R')


model <- count ~ workingday + weather + temp + humidity + windspeed + poly(hour, 2)
poi_fit <- glm(formula = model, data = dat_tr, family = poisson)
summary(poi_fit)
plot(poi_fit)

# dispersion statistic
pchi2 <- sum(residuals(poi_fit, type = 'pearson')^2)
disp <- pchi2/poi_fit$df.residual
disp

# chi square test
obs_counts <- table(dat_tr$count)[1:100]
exp_probs <- sapply(1:100, function(x) dpois(x, poi_fit$fitted.values))
exp_counts <- round(apply(exp_probs, 2, sum))

# table
rbind(obs_counts, exp_counts)

# plot
plot(1:100, obs_counts, pch = 19, col = 'red', xlab = 'count', ylim=c(0, max(obs_counts)))
lines(1:100, obs_counts, col = 'red')
points(1:100, exp_counts, pch = 19, col = 'blue')
lines(1:100, exp_counts, col = 'blue')
legend('topright', c('obs', 'exp'), pch=19, col=c('red', 'blue'))
