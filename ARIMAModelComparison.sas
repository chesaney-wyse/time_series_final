/* Define library */
libname ts5 "C:\Users\willm\OneDrive - North Carolina State University\Time Series\Homework\Final Project";

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


*FIT MA(1), AR(1) and seasonal AR(1) on full data for validation; 
proc arima data=ts5.full_v;
identify var=pm2 crosscorr=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 tsq) stationarity=(adf=2); 
estimate input=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 tsq) p=(1) q=(1);
forecast lead=12 out=model; * lead=12 when we want to forecast out to 66 obs
								note that there are no actual pm2 values for obs
								61-66;
run;
quit; 



*MAPE and MAE for MA(1), AR(1) and seasonal AR(1);
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