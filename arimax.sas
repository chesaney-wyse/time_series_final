
data monthly_vals monthly_vals_train monthly_vals_valid;
	set ts5.monthly_vals;
	if month = 1 then jan = 1; else jan = 0;
	if month = 2 then feb = 1; else feb = 0;
	if month = 3 then mar = 1; else mar = 0;
	if month = 4 then apr = 1; else apr = 0;
	if month = 5 then may = 1; else may = 0;
	if month = 6 then jun = 1; else jun = 0;
	if month = 7 then jul = 1; else jul = 0;
	if month = 8 then aug = 1; else aug = 0;
	if month = 9 then sep = 1; else sep = 0;
	if month = 10 then oct = 1; else oct = 0;
	if month = 11 then nov = 1; else nov = 0;
	pi=constant("pi");
	sin1=sin(2*pi*1*_n_/12);
	sin2=sin(2*pi*2*_n_/12);
	sin3=sin(2*pi*3*_n_/12);
	sin4=sin(2*pi*4*_n_/12);
	sin5=sin(2*pi*5*_n_/12);
	sin6=sin(2*pi*6*_n_/12);
	cos1=cos(2*pi*1*_n_/12);
	cos2=cos(2*pi*2*_n_/12);
	cos3=cos(2*pi*3*_n_/12);
	cos4=cos(2*pi*4*_n_/12);
	cos5=cos(2*pi*5*_n_/12);
	cos6=cos(2*pi*6*_n_/12);
	no2l1=lag(no2);
	no2l2=lag(no2l1);
	no2l3=lag(no2l2);
	col1=lag(co);
	col2=lag(col1);
	col3=lag(col2);
	so2l1=lag(so2);
	so2l2=lag(so2l1);
	so2l3=lag(so2l2);
	awndl1=lag(awnd);
	awndl2=lag(awndl1);
	awndl3=lag(awndl2);
	prcpl1=lag(prcp);
	prcpl2=lag(prcpl1);
	prcpl3=lag(prcpl2);
	snowl1=lag(snow);
	snowl2=lag(snowl1);
	snowl3=lag(snowl2);
	snwdl1=lag(snwd);
	snwdl2=lag(snwdl1);
	snwdl3=lag(snwdl2);
	tavgl1=lag(tavg);
	tavgl2=lag(tavgl1);
	tavgl3=lag(tavgl2);
	tmaxl1=lag(tmax);
	tmaxl2=lag(tmaxl1);
	tmaxl3=lag(tmaxl2);
	tminl1=lag(tmin);
	tminl2=lag(tminl1);
	tminl3=lag(tminl2);
	wsf2l1=lag(wsf2);
	wsf2l2=lag(wsf2l1);
	wsf2l3=lag(wsf2l2);
	wsf5l1=lag(wsf5);
	wsf5l2=lag(wsf5l1);
	wsf5l3=lag(wsf5l2);
	wt01l1=lag(wt01);
	wt01l2=lag(wt01l1);
	wt01l3=lag(wt01l2);
	if t =< 54 then output monthly_vals_train;
	if t > 54 then output monthly_vals_valid;
	output monthly_vals;
run;


proc glmselect data=monthly_vals;
	model pm2= no2 no2l1 no2l2 no2l3 co col1 col2 col3 so2 so2l1 so2l2 so2l3 awnd awndl1 awndl2 awndl3 prcp prcpl1
	prcpl2 prcpl3 snow snowl1 snowl2 snowl3 snwd snwdl1 snwdl2 snwdl3 tavg tavgl1 tavgl2 tavgl3 tmax tmaxl1 tmaxl2
	tmaxl3 tmin tminl1 tminl2 tminl3 wsf2 wsf2l1 wsf2l2 wsf2l3 wsf5 wsf5l1 wsf5l2 wsf5l3 wt01 wt01l1 wt01l2 wt01l3
	/ selection=stepwise slstay=0.05;
run;

data monthly_vals_arima;
	set monthly_vals;
	if t > 54 then pm2=.;
run;

proc arima data=work.monthly_vals_arima;
	identify var=pm2 crosscor=(co so2l1 snow tmin);
	estimate input=(co so2l1 snow tmin) p=1;
	forecast lead=6 out=pm2f;
run;
quit;

data mapes;
	merge pm2f monthly_vals;
	ape=abs((pm2-forecast)/pm2);
	ae = abs(forecast-pm2);
run;

proc means data=mapes mean;
	var ape ae;
run;

proc arima data=monthly_vals;
	identify var=pm2 crosscor=(co so2l1 snow tmin);
	estimate input=(co so2l1 snow tmin) p=1;
	forecast lead=6 out=arimaxf;
run;
quit;

proc arima data=monthly_vals;
	identify var=tmin stationarity=(adf=3);
run;
quit;

proc arima data=monthly_vals;
	identify var=co crosscor=(jan feb mar apr may jun jul aug sep oct nov);
	estimate input=(jan feb mar apr may jun jul aug sep oct nov);
	forecast lead=6;
run;

proc arima data=monthly_vals;
	identify var=co crosscor=(sin1 sin2 sin3 cos1 cos2 cos3);
	estimate input=(sin1 sin2 sin3 cos1 cos2 cos3);
	forecast lead=6 out=co;
run;

proc arima data=monthly_vals;
	identify var=so2l1 crosscor=(sin1 sin2 sin3 sin4 sin5 sin6 cos1 cos2 cos3 cos4 cos5 cos6);
	estimate input=(sin1 sin2 sin3 sin4 sin5 sin6 cos1 cos2 cos3 cos4 cos5 cos6) p=(1,5) q=(1,5);
	forecast lead=6;
run;

proc arima data=monthly_vals;
	identify var=so2l1 crosscor=(jan feb mar apr may jun jul aug sep oct nov);
	estimate input=(jan feb mar apr may jun jul aug sep oct nov) p=(1,5) q=(1,5);
	forecast lead=6 out=so2;
run;
quit;


data monthly_vals_fcst;
	set monthly_vals;
	set co (keep=forecast);
	set so2 (rename=(forecast=so2l1f) keep=forecast);
	if t > 60 then co=forecast;
	if t > 60 then so2l1=so2l1f;
run;


proc arima data=monthly_vals_fcst;
	identify var=pm2 crosscor=(co so2l1 snow tmin);
	estimate input=(co so2l1 snow tmin) p=1;
	forecast lead=6 out=forecast;
run;
quit;



proc arima data=monthly_vals;

quit;
