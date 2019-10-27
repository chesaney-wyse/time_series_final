##Neural Networks
# Needed Libraries
library(haven)
library(forecast)
library(fma)
library(tseries)
library(expsmooth)
library(lmtest)
library(zoo)
library(caschrono)
library(TSA)
library(quantmod)
#reading in aggregate data
monthly <- read.csv(“monthly_vals.csv”)
head(file)
monthly <- monthly[1:60,]
#monthly <- monthly[ -c(61:70), ]
# Creating Time Series Data Objects #
ts_object <- ts(monthly$pm2, start = 2014, frequency = 12)
#split data
training=subset(ts_object,end=length(ts_object)-6)
test=subset(ts_object,start=length(ts_object)-5)
#creating dummy variables for train
temp_training = factor(monthly$month)
reg.train=model.matrix(~temp_training)[1:54,]
reg.train=reg.train[,-1]
#creating dummy variables for test
temp_test = factor(monthly$month)
reg.test=model.matrix(~temp_test)[55:60,]
reg.test=reg.test[,-1]
#arima model based on train
Model.four<-Arima(training,order=c(1,0,1),xreg=reg.train, method = ‘ML’)
#this builds a neural net model using the residuals from the ARIMA model train
NN.Model2<-nnetar(Model.four$residuals,p=1,P=1,size=2)
#using neural net model to forecast 6 points forward (train)
#(i.e. the time points in the validation)
NN.Forecast2<-forecast(NN.Model2,h=6)
#part of our forecast,
#becasue the neural net was built with residuals
#we have to add the seasonal component (base_forecast) to the neural net forecasts
Base_forecast = forecast(Model.four,h=6,xreg = reg.test)
#Adding the base_forecast to the forecast from our neural net
#actual predictions from our neural net
Final_forecast = Base_forecast$mean + NN.Forecast2$mean
#takes the actual test (validation) values of PM2.5 and
#subtracts our predictions to get the error
error_nnet = test - Final_forecast
MAE=mean(abs(error_nnet))  #1.6
MAPE=mean(abs(error_nnet)/abs(test)) #0.17