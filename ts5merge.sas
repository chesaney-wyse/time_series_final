libname ts5 "C:\Users\bjsul\Documents\NCSU\MSA\Fall\Time-Series";

proc import datafile="C:\Users\bjsul\Documents\NCSU\MSA\Fall\Time-Series\pm_2_5_Raleigh2.csv" dbms=csv
	out=work.pm2;
run;

data work.pm2_2;
	set work.pm2 (rename=(Daily_Mean_PM2_5_Concentration=pm2));
	if pm2 =< 0 then delete;
	month=month(date);
	year=year(date);
run;

proc sql;
	create table monthly_pm2 as
	select avg(pm2) as pm2, month, year
	from work.pm2_2
	group by year, month;
quit;

data monthly_pm2;
	set monthly_pm2;
	t=_n_;
run;







proc import datafile="C:\Users\bjsul\Documents\NCSU\MSA\Fall\Time-Series\SO2_Raleigh.csv" dbms=csv
	out=work.so2 replace;
run;

data work.so2;
	set work.so2 (rename=(Daily_Max_1_hour_SO2_Concentrati=so2));
	if so2 =< 0 then delete;
	month=month(date);
	year=year(date);
run;

proc sql;
	create table monthly_so2 as
	select avg(so2) as so2, month, year
	from work.so2
	group by year, month;
quit;

data monthly_so2;
	set monthly_so2;
	t = _n_;
run;




proc import datafile="C:\Users\bjsul\Documents\NCSU\MSA\Fall\Time-Series\NO_Raleigh.csv" dbms=csv
	out=work.no replace;
run;

data work.no2;
	set work.no (rename=(Daily_Max_1_hour_NO2_Concentrati=no2));
	if no2 =< 0 then delete;
	month=month(date);
	year=year(date);
run;

proc sql;
	create table monthly_no2 as
	select avg(no2) as no2, month, year
	from work.no2
	group by year, month;
quit;

data monthly_no2;
	set monthly_no2;
	t = _n_;
run;







proc import datafile="C:\Users\bjsul\Documents\NCSU\MSA\Fall\Time-Series\CO_Raleigh.csv" dbms=csv
	out=work.CO replace;
run;

data work.co;
	set work.co (rename=(Daily_Max_8_hour_CO_Concentratio=co));
	if co =< 0 then delete;
	month=month(date);
	year=year(date);
run;

proc sql;
	create table monthly_co as
	select avg(co) as co, month, year
	from work.co
	group by year, month;
quit;

data monthly_co;
	set monthly_co;
	t = _n_;
run;




proc import datafile="C:\Users\bjsul\Documents\NCSU\MSA\Fall\Time-Series\Weatherdata.csv" dbms=csv
	out=weather;
run;

data work.weather;
	set work.weather;
	month=month(date);
	year=year(date);
run;

proc sql;
	create table monthly_weather as
	select avg(awnd) as awnd, sum(prcp) as prcp, sum(snow) as snow, sum(snwd) as snwd, avg(tavg) as tavg,
	max(TMAX) as tmax, min(tmin) as tmin, max(wsf2) as wsf2, max(wsf5) as wsf5, sum(WT01) as wt01,month, year
	from work.weather
	group by year, month;
quit;

data monthly_weather;
	set monthly_weather;
	t = _n_;
run;
	
data ts5.monthly_vals;
	merge monthly_pm2 monthly_no2 monthly_co monthly_so2 monthly_weather;
	by t;
run;

proc export data=ts5.monthly_vals outfile="C:\Users\bjsul\Documents\NCSU\MSA\Fall\Time-Series\monthly_vals.csv" dbms=csv replace;
run;
