# source ------------------------------------------------------------------
source('./R/data_cleansing.R')
library(gridExtra)

# before decomposition
g1 <- ggplot(data_tr[weekend == 'no']) + 
  geom_boxplot(aes(x=season, y=count, fill=season)) + 
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4')) + 
  ylim(c(0,1000)) + guides(fill=F) + ggtitle('weekend : no')
g2 <- ggplot(data_tr[weekend == 'yes']) + 
  geom_boxplot(aes(x=season, y=count, fill=season)) + 
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4')) +
  ylim(c(0,1000)) + guides(fill=F) + ggtitle('weekend : yes')
grid.arrange(g1, g2, ncol=2)


g1 <- ggplot(data_tr[weekend == 'no']) + 
  geom_boxplot(aes(x=weather, y=count, fill=weather)) + 
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4')) + 
  ylim(c(0,1000)) + guides(fill=F) + ggtitle('weekend : no')
g2 <- ggplot(data_tr[weekend == 'yes']) + 
  geom_boxplot(aes(x=weather, y=count, fill=weather)) + 
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4')) +
  ylim(c(0,1000)) + guides(fill=F) + ggtitle('weekend : yes')
grid.arrange(g1, g2, ncol=2)



g1 <- ggplot(data_tr[weekend == 'no']) + 
  geom_point(aes(x=temp, y=count)) + 
  geom_smooth(aes(x=temp, y=count), method = 'lm')
  
g2 <- ggplot(data_tr[weekend == 'yes']) + 
  geom_point(aes(x=temp, y=count)) + 
  geom_smooth(aes(x=temp, y=count), method = 'lm') +
  scale_y_continuous(limits = c(0,1000)) 
grid.arrange(g1, g2, ncol=2)


# decomposition
data_mean <- data_tr[
  ,
  .(
    mean_casual = mean(casual),
    mean_registered = mean(registered), 
    mean_count = mean(count)
  ),
  by = c('weekend', 'hour')
]
data_mean <- data_mean[order(weekend, hour), ]

data_pre <- data_tr[data_mean, on = c('weekend', 'hour')]
data_pre$casual <- data_pre$casual - data_pre$mean_casual
data_pre$registered <- data_pre$registered - data_pre$mean_registered
data_pre$count <- data_pre$count - data_pre$mean_count

# after decomposition
g1 <- ggplot(data_pre[weekend == 'no']) + 
  geom_boxplot(aes(x=season, y=count, fill=season)) + 
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4')) + 
  ylim(c(0,500)) + guides(fill=F) + ggtitle('weekend : no')
g2 <- ggplot(data_pre[weekend == 'yes']) + 
  geom_boxplot(aes(x=season, y=count, fill=season)) + 
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4')) +
  ylim(c(0,500)) + guides(fill=F) + ggtitle('weekend : yes')
grid.arrange(g1, g2, ncol=2)


g1 <- ggplot(data_pre[weekend == 'no']) + 
  geom_boxplot(aes(x=weather, y=count, fill=weather)) + 
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4')) + 
  ylim(c(0,500)) + guides(fill=F) + ggtitle('weekend : no')
g2 <- ggplot(data_pre[weekend == 'yes']) + 
  geom_boxplot(aes(x=weather, y=count, fill=weather)) + 
  scale_fill_manual(values=c('pink', 'skyblue', 'brown', 'dodgerblue4')) +
  ylim(c(0,500)) + guides(fill=F) + ggtitle('weekend : yes')
grid.arrange(g1, g2, ncol=2)


g1 <- ggplot(data_pre[weekend == 'no']) + 
  geom_point(aes(x=temp, y=count)) + 
  geom_smooth(aes(x=temp, y=count), method = 'lm')
g2 <- ggplot(data_pre[weekend == 'yes']) + 
  geom_point(aes(x=temp, y=count)) + 
  geom_smooth(aes(x=temp, y=count), method = 'lm') +
  scale_y_continuous(limits = c(0,1000)) 
grid.arrange(g1, g2, ncol=2)



cor(data_tr[weekend == 'no']$temp, data_tr[weekend == 'no']$count)
cor(data_pre[weekend == 'no']$temp, data_pre[weekend == 'no']$count)
cor(data_tr[weekend == 'yes']$temp, data_tr[weekend == 'yes']$count)
cor(data_pre[weekend == 'yes']$temp, data_pre[weekend == 'yes']$count)


cor(data_tr[weekend == 'no']$atemp, data_tr[weekend == 'no']$count)
cor(data_pre[weekend == 'no']$atemp, data_pre[weekend == 'no']$count)
cor(data_tr[weekend == 'yes']$atemp, data_tr[weekend == 'yes']$count)
cor(data_pre[weekend == 'yes']$atemp, data_pre[weekend == 'yes']$count)


cor(data_tr[weekend == 'no']$humidity, data_tr[weekend == 'no']$count)
cor(data_pre[weekend == 'no']$humidity, data_pre[weekend == 'no']$count)
cor(data_tr[weekend == 'yes']$humidity, data_tr[weekend == 'yes']$count)
cor(data_pre[weekend == 'yes']$humidity, data_pre[weekend == 'yes']$count)


cor(data_tr[weekend == 'no']$windspeed, data_tr[weekend == 'no']$count)
cor(data_pre[weekend == 'no']$windspeed, data_pre[weekend == 'no']$count)
cor(data_tr[weekend == 'yes']$windspeed, data_tr[weekend == 'yes']$count)
cor(data_pre[weekend == 'yes']$windspeed, data_pre[weekend == 'yes']$count)


data_tr
hist(data_pre[weekend == 'yes', ]$count)
hist(data_pre[weekend == 'no', ]$count)

qqnorm(data_pre[weekend == 'yes', ]$count)
qqline(data_pre[weekend == 'yes', ]$count)

qqnorm(data_pre[weekend == 'no', ]$count)
qqline(data_pre[weekend == 'no', ]$count)

qqnorm()


plot(data_pre[weekend == 'yes', ]$hour, data_pre[weekend == 'yes', ]$count)
plot(data_pre[weekend == 'no', ]$hour, data_pre[weekend == 'no', ]$count)

plot(data_tr[weekend == 'yes', ]$hour, data_tr[weekend == 'yes', ]$count)
plot(data_tr[weekend == 'no', ]$hour, data_tr[weekend == 'no', ]$count)


data_pre_yes <- data_pre[weekend == 'yes', ]
data_pre_no <- data_pre[weekend == 'no', ]
data_tr_yes <- data_tr[weekend == 'yes', ]
data_tr_no <- data_tr[weekend == 'no', ]

m <- lm(count~temp, data_tr_yes)
summary(m)
library(lmtest)
dwtest(data_tr_yes$count~data_tr_yes$temp)


m <- lm(count~temp, data_pre_yes)
summary(m)
library(lmtest)
dwtest(data_pre_yes$count~data_pre_yes$temp)

boxplot(temp~weather, data_tr)
boxplot(humidity~weather, data_tr)
boxplot(windspeed~weather, data_tr)



tmp_data <- data_tr_no
tmp_list <- split(tmp_data, tmp_data$date)
dev.off()
par(mfrow=c(3,3))
corrs <- c()
ps <- c()
length(tmp_list)
xnames <- 'hour'
for (i in 1:132) {
  x <- tmp_list[[i]][[xnames]]
  y <- tmp_list[[i]]$count
  
  y <- y[order(x)]
  x <- x[order(x)]
  
  # m <- lm(y~x+I(x^1))
  m <- loess(y~x)
  corr <- cor(x,y); corrs[i] <- corr
  temp_mean <- mean(tmp_list[[i]]$temp)
  plot(
    x,y, main=c(round(corr,2), round(temp_mean, 2)), 
    xlim = c(min(tmp_data[[xnames]]), max(tmp_data[[xnames]])),
    ylim = c(min(tmp_data[['count']]), max(tmp_data[['count']]))
  )
  lines(x,m$fitted)
}
hist(corrs %>% abs)
summary(corrs %>% abs)


dev.off()

m <- loess(count~hour, tmp_data, span = 0.2)
plot(tmp_data$hour, tmp_data$count, pch=19, col=alpha('black', 0.2))
lines(tmp_data$hour[order(tmp_data$hour)], m$fitted[order(tmp_data$hour)], 
      lwd = 5, col='red')

library(mgcv)

gam()

