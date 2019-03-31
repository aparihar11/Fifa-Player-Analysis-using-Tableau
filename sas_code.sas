/*Specify the libname for the project*/
libname c "C:/Users/aparihar/Desktop/retakes/tableau_project/";

/*Import the csv files and converted in SAS format*/

proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\accidents_2017.csv" out = c.accidents replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\air_quality_Nov2017.csv" out = c.air_quality replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\air_stations_Nov2017.csv" out = c.air_stations replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\births.csv" out = c.births replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\bus_stops.csv" out = c.bus_stops replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\deaths.csv" out = c.deaths replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\immigrants_by_nationality.csv" out = c.imm_by_nationality replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\immigrants_emigrants_by_age.csv" out = c.immi_emi_by_age replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\immigrants_emigrants_by_destination.csv" out = c.immiemibydest replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\immigrants_emigrants_by_destination2.csv" out = c.immiemibydest2 replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\immigrants_emigrants_by_sex.csv" out = c.immiemibysex replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\most_frequent_baby_names.csv" out = c.babynames replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\most_frequent_names.csv" out = c.names replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\population.csv" out = c.population replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\transports.csv" out = c.transports replace;
run;
proc import datafile = "C:\Users\aparihar\Desktop\retakes\tableau_project\unemployment.csv" out = c.unemployment replace;
run;




/* split airquality stations by district */
 
proc sql;
create table c.airquality_new as
select *,

scan(Station,2,"-") as District_Name,
scan(Generated,1," ") as Generated_Date, scan(Generated,2," ") as Generated_Hours
from c.air_quality
Order by District_Name,Generated;
quit;

/* convert in date format */

proc sql;
create table c.airquality_new as
select *,input(strip(Generated_Date), ddmmyy10.) as report_date format=ddmmyy10.
from c.airquality_new;
quit;

/* Clean airquality data  */
data c.Airquality_new;
set c.Airquality_new;
O3_Hour= compress(O3_Hour,'h');
NO2_Hour=compress(NO2_Hour,'h');
run;




/* sum deaths by age group */

proc sql;
create table c.death_agegroup as
select Age,
sum(Number) as TotalDeath
from c.Deaths
Group by Age;
quit;

/* sum deaths by district */

proc sql;
create table c.death_district as 
select District_Name, sum(Number) as TotalDeath,Year
from c.Deaths
Group by Year,District_Name;
quit;

/* accidents in Nov */
proc sql;
create table c.Accidents_Nov as
select *
from c.Accidents
where Month = 'November';
quit;






/*  sum no. of victims by month */

proc sql;
create table c.Accidents_Month as
select Month, sum(Victims) as TotalVictims
from c.Accidents
Group by Month;
quit;














