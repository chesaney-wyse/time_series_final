/* Define library */
libname ts5 "C:\Users\willm\OneDrive - North Carolina State University\Time Series\Homework\Final Project";

*explore stationarity about the season of training set;
proc arima data=ts5.train plots=all;
	identify var=pm2 stationarity=(adf=2 dlag=12); 
run;
quit;

/* Fit dummy vars for stationary */
data ts5.mv_t replace;
set ts5.train (obs=66);
tsq = t**2; * square the t term to account for quadratic trend (like y=x^2);
if month=1 then seas1=1; else seas1=0;
if month=2 then seas2=1; else seas2=0;
if month=3 then seas3=1; else seas3=0;
if month=4 then seas4=1; else seas4=0;
if month=5 then seas5=1; else seas5=0;
if month=6 then seas6=1; else seas6=0;
if month=7 then seas7=1; else seas7=0;
if month=8 then seas8=1; else seas8=0;
if month=9 then seas9=1; else seas9=0;
if month=10 then seas10=1; else seas10=0; 
if month=11 then seas11=1; else seas11=0; 
run;


*check fit of dummy variables and explore residuals to look for presence of trend;
proc arima data=ts5.mv_t plots=all;
identify var=pm2 crosscorr=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11); 
estimate input=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11);
forecast back=12 lead=12 out=season_adj;
run;
quit;
/* quadratic trend in residuals; so fit a quadratic model to the data */

/* With quadratic model fit */
proc arima data=ts5.mv_t plots=all;
identify var=pm2 crosscorr=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 tsq) stationarity=(adf=2); 
estimate input=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 tsq);
forecast lead=6 out=ts5.check_model;
run;
quit; 
/* Residuals appear to be normally distributed with constant variance.
	Residuals are also stationary about trend */ 


/* Fit AR/MA terms to try to reduce to white noise */
proc arima data=ts5.mv_t;
identify var=pm2 crosscorr=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 tsq) stationarity=(adf=2); 
estimate input=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 tsq) p=(1) q=(1);
forecast back=6 lead=6 out=final_1;
run;
quit; 
/* We have white noise */



/* Now we need the validation accuracy */
*extract month from date column to use for dummy vars;
data ts5.full replace;
set ts5.monthly_vals(obs=66);
*month = month(date); * month is already a variable;
run;

proc print data=ts5.monthly_vals;
run;

*Fit dummy vars to full data;
data ts5.full replace;
set ts5.monthly_vals (obs=66);
tsq = t**2; * square the t term to account for quadratic trend (like y=x^2);
if month=1 then seas1=1; else seas1=0;
if month=2 then seas2=1; else seas2=0;
if month=3 then seas3=1; else seas3=0;
if month=4 then seas4=1; else seas4=0;
if month=5 then seas5=1; else seas5=0;
if month=6 then seas6=1; else seas6=0;
if month=7 then seas7=1; else seas7=0;
if month=8 then seas8=1; else seas8=0;
if month=9 then seas9=1; else seas9=0;
if month=10 then seas10=1; else seas10=0; 
if month=11 then seas11=1; else seas11=0; 
run;


/* Prep data for validation */
data ts5.full_v;
	set ts5.full;
	if _N_ > 54 then pm2 = .;
run;


*FIT ARMA(1,0,1)(1,0,0)12 for seasonal ARIMA or AR(2) for non-seasonal ARIMA; 
proc arima data=ts5.full_v;
identify var=pm2 crosscorr=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 tsq) stationarity=(adf=2); 
estimate input=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 tsq) p=(1)(12) q=(1);
forecast lead=12 out=model; * lead=12 when we want to forecast out to 66 obs
								note that there are no actual pm2 values for obs
								61-66;
run;
quit; 



*MAPE and MAE to assess model performance on validation set;
data fit_model replace; 
merge model ts5.full;

if _N_ >54; 
	residual = pm2 - FORECAST;
	AE = abs(residual);
	APE = (abs(residual)/pm2)*100;
run;

proc means data=fit_model;
var AE APE;
run;

/* Export forecasts to Excel */
proc export 
  data=work.model 
  dbms=xlsx 
  outfile="C:\Users\willm\OneDrive - North Carolina State University\Time Series\Homework\Final Project\forecasts.csv" 
  replace;
run;