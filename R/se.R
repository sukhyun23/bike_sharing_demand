
library(sandwich)

source('./R/data_cleansing.R')

head(data_tr)
poi <- glm(
  # count~season+holiday+temp+humidity+windspeed+hour+I(hour^2),
  count~season+holiday+temp+humidity+windspeed,
  data = data_tr, family = poisson
)
summary(poi)

round(
  rbind(
    summary(poi)$coefficients[,2],
    sqrt(diag(vcovHC(poi))),
    sqrt(diag(vcovCL(poi, ~ date)))
  ),
  5
)
