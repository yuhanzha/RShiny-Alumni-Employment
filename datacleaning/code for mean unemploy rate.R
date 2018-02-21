library(readxl)
dat <- read_xls('../data/Unemployment.xls')
dat <- data.frame(dat)
dat <- na.omit(dat)
colnames(dat) <- dat[1,]
dat <- dat[-1,]


dat$State <- factor(dat$State)

s1 <- split(dat, dat$State)
f <- function(lis){
  return(mean(as.numeric(lis[,46])))
}
avg <- sapply(s1, f)
d <- data.frame(names(avg), avg)
write.csv('d',file = '../output/mean_employment_rate.csv')

