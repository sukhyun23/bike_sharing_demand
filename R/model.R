# source ------------------------------------------------------------------
source('./R/data_cleansing.R')


data_tr

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


