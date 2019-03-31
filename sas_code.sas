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


/* #################################################################AIRQUALITY - ACCIDENT data ###########################################*/


/*  sum no. of victims by month */

proc sql;
create table c.Accidents_Month as
select Month, sum(Victims) as TotalVictims
from c.Accidents
Group by Month;
quit;

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





/* accidents in Nov */
proc sql;
create table c.Accidents_Nov as
select *
from c.Accidents
where Month = 'November';
quit;




/* accidents by part of day */
proc sql;
create table c.Accidents_time as
select Part_of_the_day,sum(Victims) as totalfatalities
from c.Accidents
group by Part_of_the_day;
quit;


/* accidents by day of week */
proc sql;
create table c.Accidents_Weekday as
select Weekday,sum(Victims) as totalfatalities
from c.Accidents
group by Weekday;
quit;



/* #################################################################TRANSPORT data ###########################################*/



/* merge bus and tram files */ 
PROC SQL;
CREATE TABLE c.AllTransport as
SELECT * from  c.Bus_stops
union
SELECT * from  c.Transports;
RUN;





/* #################################################################UNEMPLOYMENT data ###########################################*/


/*  Unemployment   */

proc sql;
CREATE TABLE c.Unemployment_Year as
SELECT Year, Demand_Occupation,Gender, sum(Number) as Number_year
from c.unemployment
Group by Year,Demand_Occupation,Gender;
run;





/* #################################################################DEATH- BIRTH data ###########################################*/


/* sum deaths by age group */

proc sql;
create table c.death_agegroup as
select Age,
sum(Number) as TotalDeath
from c.Deaths
Group by Age;
quit;

/* sum deaths by year */

proc sql;
create table c.death_district as 
select sum(Number) as TotalDeath,Year
from c.Deaths
Group by Year;
quit;



/* sum birth by Year */

proc sql;
create table c.birth_Year as
select input(Year, 18.) as Year, 
sum(Number) as Total_born
from c.Births
Group by Year;
quit;


/*  merging birth death table  */


PROC sql;
create table c.birth_death as 
select * from c.birth_Year as x , c.Death_year as y  
where x.Year=y.Year;
quit;


/* #################################################################POPULATION-IMMIGRATION data ###########################################*/



/*  population by gender,year  */
proc sql;
create table c.population_gender as 
select Gender, Year,sum(Number) as tota_pop
from c.Population
group by Gender, Year;
quit;


/* by age group*/

proc sql;
create table c.population_age as 
select Gender, Age, Year,sum(Number) as tota_pop
from c.Population
group by Gender,Age, Year;
quit;

/* immigrant concentration in areas */
proc sql;
create table c.population_nationality as 
select Neighborhood_Name,Nationality,Number
from c.Imm_by_nationality
where Number GE 100 & Nationality NE 'Spain';
quit;


/* immigrant concentration in areas */
proc sql;
create table c.population_nationalitycount as 
select Nationality,sum(Number) as Total
from c.Imm_by_nationality
Group by Nationality;
quit;







/* #################################################################NAMES- data ###########################################*/

PROC sql;
create table c.babynames_clean as 
select Name,Gender, sum(Frequency) as total_freq
from c.Babynames
Group by Name, Gender;
quit; 
quit;



proc sql;
create table c.names_clean as 
select Name,Gender,Frequency
from c.Names
where Decade='TOTAL';
quit;







