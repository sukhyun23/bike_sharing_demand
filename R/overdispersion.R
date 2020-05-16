# source ------------------------------------------------------------------
source('./R/data_cleansing.R')

data_tr %>% head()

form <- count ~ workingday + weather + 
  temp + humidity + windspeed + hour + I(hour^2)
poi_mod <- glm(formula = form, data = data_tr, family = poisson)

# dispersion statistic
pchi2 <- sum(residuals(poi_mod, type = 'pearson')^2)
disp <- pchi2/poi_mod$df.residual

# chi square test
obs_counts <- table(data_tr$count)[1:100]
exp_probs <- sapply(1:100, function(x) dpois(x, poi_mod$fitted.values))
exp_counts <- round(apply(exp_probs, 2, sum))

# table
rbind(obs_counts, exp_counts)

# plot
plot(1:100, obs_counts, pch = 19, col = 'red', xlab = 'count')
lines(1:100, obs_counts, col = 'red')
points(1:100, exp_counts, pch = 19, col = 'blue')
lines(1:100, exp_counts, col = 'blue')
legend('topright', c('obs', 'exp'), pch=19, col=c('red', 'blue'))


plot(data_tr$count, poi_mod$fitted.values)
cor(data_tr$count, poi_mod$fitted.values)^2
