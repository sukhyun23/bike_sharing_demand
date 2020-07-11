# source ------------------------------------------------------------------
source('./R/data_cleansing.R')
source('./R/functions.R')

library(mgcv)
library(plotly)
library(reshape2)

day_profile_plot(dat_tr, 'weekend', 'count', c(1,2))
day_profile_plot(dat_tr, 'weekend', 'registered', c(1,2))
day_profile_plot(dat_tr, 'workingday', 'casual', c(1,2))

plot(dat_tr$hour, dat_tr$casual, 'n', xlab = 'hour', ylab = 'count')
f <- function(d) {
  lines(d$hour, d$casual, col=alpha(1, 0.3))
  invisible(NULL)
}
dat_sub <- dat_tr[, c('hour', 'casual', 'date')]
dat_list <- split(dat_sub, dat_sub$date)
a <- lapply(dat_list, f); rm(a)