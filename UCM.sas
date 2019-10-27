libname ts "Z:/Desktop/IAA/Time Series 2";

proc ucm data=ts.monthly_vals;
level;
slope;
season length=12 type=dummy;
irregular;
model pm2=t;
run;


*level, trend and season are deterministic -> concluded from p-values of parameter estimates;
*Then looked at significance analysis of components -> level and season are significant, trend is not;


*variance = 0 for level and season bc they are deterministic; 
*add in acf and pacf plots to determine AR and MA terms to add;
proc ucm data=ts.monthly_vals;
level variance=0 plot=smooth;
season length=12 type=dummy variance=0 plot=smooth;
irregular;
model pm2=t;
estimate plot=(acf pacf wn);
run;

* Add AR1 term;
proc ucm data=ts.monthly_vals;
level variance=0 plot=smooth;
season length=12 type=dummy variance=0 plot=smooth;
irregular p=1;
model pm2=t;
estimate plot=(acf pacf wn);
run;

*white noise is achieved;

*forecast out;
proc ucm data=ts.monthly_vals;
level variance=0 plot=smooth;
season length=12 type=dummy variance=0 plot=smooth;
irregular p=1;
model pm2=t;
estimate plot=(acf pacf wn);
forecast back=6 lead=6 outfor=work.pred;
run;

*MAPE and MAE;
data eval; 
	set work.pred;
	AE = abs(pm2-forecast);
	APE = (abs(pm2-forecast)/pm2)*100;
run;

proc means data=eval;
var AE APE;
where t > 54;
run;

*MAPE:17.4962609;
*MAE: 1.7502366;
