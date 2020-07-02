# source ------------------------------------------------------------------
source('./R/data_cleansing.R')

dat_tr %>% head()

model <- count ~ workingday + weather + temp + humidity + windspeed + poly(hour, 2)
poi_fit <- glm(formula = model, data = dat_tr, family = poisson)
summary(poi_fit)
plot(poi_fit)

# dispersion statistic
pchi2 <- sum(residuals(poi_fit, type = 'pearson')^2)
disp <- pchi2/poi_fit$df.residual

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

# 1. poisson model
# 1.1 count variable? yes
# 1.2 non zero? yes
# 1.3 y indeperndent? no longitudinal
# 1.4 equal empirical mean variance? no var is greater than mean
# overdispersed..

# 2. what is overdispersion 
# 2.1 In statistics, overdispersion is the presence of greater variability (statistical dispersion) in a data set than would be expected based on a given statistical model. 
# 2.2 underestimate var of coeff 

# 3. why overdispersed
# 3.1 omitted important variables
# 3.2 outlier
# 3.3 interactions
# 3.4 proper transformation 
# 3.5 sparse data
# i think longitudinal data -> overdispersed

# 4. how to know overdispersion
# 4.1 exp vs obs
# 4.2 emprical mean vs variance
# 4.3 dispersion statistic

# 5. model
# 5.1 hour explain -> weekend / weekday <- commute?
# 5.2 include non-linearity of hour -> GAM 

