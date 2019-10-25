library("haven")
library("lubridate")
library("forecast")
library("tseries")
library("TSPred")

set.seed(10232019)

data <- read_sas("C:\\Users\\bjsul\\Documents\\NCSU\\MSA\\Fall\\Time-Series\\monthly_vals.sas7bdat")
data2 <- data[1:60,]
data2.train <- data2[1:54,]
data2.valid <- data2[55:60,]


pm2.train <- ts(data2.train$pm2, start=2014, frequency = 12)
pm2.valid <- ts(data2.valid$pm2, start=2018.5, frequency = 12)



index.ts <- seq(1,length(pm2.train))
x1.sin=sin(2*pi*index.ts*1/12)
x1.cos=cos(2*pi*index.ts*1/12)
x2.sin=sin(2*pi*index.ts*2/12)
x2.cos=cos(2*pi*index.ts*2/12)
x3.sin=sin(2*pi*index.ts*3/12)
x3.cos=cos(2*pi*index.ts*3/12)
x4.sin=sin(2*pi*index.ts*4/12)
x4.cos=cos(2*pi*index.ts*4/12)
x5.sin=sin(2*pi*index.ts*5/12)
x5.cos=cos(2*pi*index.ts*5/12)
x6.sin=sin(2*pi*index.ts*6/12)
x6.cos=cos(2*pi*index.ts*6/12)
xreg1 <- cbind(x1.sin, x1.cos, x2.sin, x2.cos, x3.sin, x3.cos, x4.sin, x4.cos, x5.sin, x5.cos)
index.tsf <- seq(1+length(pm2.train), length(pm2.train)+length(pm2.valid))
x1.sint=sin(2*pi*index.ts*1/12)
x1.cost=cos(2*pi*index.ts*1/12)
x2.sint=sin(2*pi*index.ts*2/12)
x2.cost=cos(2*pi*index.ts*2/12)
x3.sint=sin(2*pi*index.ts*3/12)
x3.cost=cos(2*pi*index.ts*3/12)
x4.sint=sin(2*pi*index.ts*4/12)
x4.cost=cos(2*pi*index.ts*4/12)
x5.sint=sin(2*pi*index.ts*5/12)
x5.cost=cos(2*pi*index.ts*5/12)
x6.sint=sin(2*pi*index.ts*6/12)
x6.cost=cos(2*pi*index.ts*6/12)
xreg1forc <- cbind(x1.sint, x1.cost, x2.sint, x2.cost, x3.sint, x3.cost, x4.sint, x4.cost, x5.sint, x5.cost)
colnames(xreg1forc) <- c("x1.sin", "x1.cos", "x2.sin", "x2.cos", "x3.sin", "x3.cos", "x4.sin", "x4.cos", "x5.sin", "x5.cos")

xreg2 <- cbind(seasonaldummy(pm2))

model1 <- arima(pm2.train, order=c(0,0,0), xreg=xreg1)

acf(pm2.train, type = "correlation")
acf(pm2.train, type = "partial")

nn.model <- nnetar(pm2.train, p=1, P=1, size=2)
MAPE(pm2.train[13:54], nn.model$fitted[13:54])
plot(nn.model$fitted)
plot(pm2.valid)

nn.frcst <-forecast(nn.model, h=6, model=nnetar)
plot(nn.frcst$mean[1:6])
MAPE(pm2.valid, nn.frcst$mean[1:6])


