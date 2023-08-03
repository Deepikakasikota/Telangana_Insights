# 1 List down the top 10 districts that have the highest number of domestic visitors overall (2016-2019) :
# insight - get an overview of districts that are doing well

# Top 10 districts of domestic visitors..
select district, sum(visitors) as visitors
from tourdata.domestic_visitors
group by district order by visitors desc limit 10;

# top 5 districts of foreign visitors..alter
select district, sum(visitors) as visitors
from tourdata.foreign_visitors
group by district order by visitors desc limit 5;

# 2 List down 3 districts based on the compounded annual growth rate (CAGR) of visitors between (2016-2019)
# insight - district that are growing

-- For Domestic
with cte as(
Select district,
sum(case when year = 2016 Then visitors else 0 End) as IV,   #all the visitors from 2016 district wise
sum(case when year = 2019 Then visitors else 0 End) as FV	 #all the visitors from 2019 district wise
from tourdata.domestic_visitors
group by district
)
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
order by CAGR desc limit 5;

 # ----------------------------------------------------------------------------------------------------------------------------#
-- For Foreign
with cte as(
Select district,
sum(case when year = 2016 Then visitors else 0 End) as IV,   #all the visitors from 2016 district wise
sum(case when year = 2019 Then visitors else 0 End) as FV	 #all the visitors from 2019 district wise
from tourdata.foreign_visitors
group by district
)
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
order by CAGR desc limit 5;

# -------------------------------------------------------------------------------------------------------------------------------#
-- For total visitors
with cte as(
select district,
sum(case when year = 2016 Then total_visitors else 0 end) as IV,
sum(case when year = 2019 Then total_visitors else 0 End) as FV	 #all the visitors from 2019 district wise
from tourdata.total_visitors
group by district
)
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
order by CAGR desc limit 5;


# 3 List down the bottom 3 districts based on compounded annual growth rate (CAGR) of visitors between (2016 - 2019)
# insight - districts that are declining

-- Domestic
with cte as(
Select district,
sum(case when year = 2016 Then visitors else 0 End) as IV,
sum(case when year = 2019 Then visitors else 0 End) as FV
from tourdata.domestic_visitors
group by district
),
cte2 as (
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
)
select * from cte2 
where CAGR is not null   -- if IV is zero we get Infinity to remove that we use cagr is not null
order by cagr limit 3;
# ----------------------------------------------------------------------------------------------------------------------------#
-- Foreign
with cte as(
Select district,
sum(case when year = 2016 Then visitors else 0 End) as IV,
sum(case when year = 2019 Then visitors else 0 End) as FV
from tourdata.foreign_visitors
group by district
),
cte2 as (
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
)
select * from cte2 
where CAGR is not null   -- if IV is zero we get Infinity to remove that we use cagr is not null
order by cagr limit 3;

-- For total visitors..
with cte as(
Select district,
sum(case when year = 2016 Then total_visitors else 0 End) as IV,
sum(case when year = 2019 Then total_visitors else 0 End) as FV
from tourdata.total_visitors
group by district
),
cte2 as (
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
)
select * from cte2 
where CAGR is not null   -- if IV is zero we get Infinity to remove that we use cagr is not null
order by cagr limit 3;


# 4 what are the peak and low season months for hyderabad based on the data from 2016 -2019 for hyderabad district only
# Peak and low in Total from 2016 - 2019

-- Domestic 
-- Top 3 months
select month as peak_season, sum(visitors) as visitors
from tourdata.domestic_visitors
where district ="Hyderabad"
group by month
order by visitors desc limit 3;

-- Last 3 months
select month as low_season, sum(visitors) as visitors
from tourdata.domestic_visitors
where district ="Hyderabad"
group by month
order by visitors limit 3;

-- Top 5 districts 
select district, sum(visitors) as visitors
from tourdata.domestic_visitors
where month ="February"
group by district
order by visitors desc limit 5;
 # ----------------------------------------------------------------------------------------------------------------------------#
-- Foreign

-- Top 5 months
select month as peak_season , sum(visitors) as visitors
from tourdata.foreign_visitors
where district ="Hyderabad"
group by month
order by visitors desc limit 3;

-- Last 3 months
select month as low_season, sum(visitors) as visitors
from tourdata.foreign_visitors
where district ="Hyderabad"
group by month
order by visitors limit 3;

# 5 show the top & bottom 3 districts with high domestic to foreign tourist ratio ?
/* insight - (government can learn from top district and replicate the same to bottom districts 
which can improve the foreign visitors as foreign visitors will bring more revenue)*/

-- Query 5

with cte as (
select D.district ,
 sum(D.visitors) as Dvisitor,sum(F.visitors) as Fvisitor
from tourdata.domestic_visitors D
join tourdata.foreign_visitors F
on D.district =F.district and D.month = F.month and D.year =F.year
group by D.district
)

select district,Dvisitor,Fvisitor,DtoFratio,top 
from(select  * ,rank() over(order by DtoFratio) as top ,rank() over(order by DtoFratio desc) as least
		from (select * ,round(Dvisitor/Fvisitor) as DtoFratio
				from cte) subquery
where DtoFratio is not null)subquery2   -- excluding foreign null values since foreignVisitors are zero
where top<4 or least<4
order by top;


 # ----------------------------------------------------------------------------------------------------------------------------#
-- Query 6
/* 6 List the top & bottom 5 districts based on ‘population to tourist footfall ratio*’ ratio in 2019? 
( ” ratio: Total Visitors / Total Residents Population in the given year)
(Insight: Find the bottom districts and create a plan to accommodate more tourists) */

-- Domestic 
with cte as (
 select p.district,year,estimated_population_2019,sum(visitors) as visitors
 from tourdata.population_1 P
 join tourdata.domestic_visitors D
 on P.district =D.district
 where year =2019 
 group by p.district,estimated_population_2019,year)
 
 select district,footfall_ratio,top from
	 (select district,(visitors/estimated_population_2019) as footfall_ratio ,
     row_number() over(order by (visitors/estimated_population_2019) desc) as top, 
     row_number() over(order by (visitors/estimated_population_2019) ) as low 
     from cte where visitors>0) subquery     
     where top<6 or low <6
 order by footfall_ratio desc;

 # ----------------------------------------------------------------------------------------------------------------------------#
-- Foreign
with cte as (
 select p.district,year,estimated_population_2019,sum(visitors) as visitors
 from tourdata.population_1 P
 join tourdata.foreign_visitors F
 on P.district =F.district
 where year =2019
 group by p.district,estimated_population_2019,year)
select district,footfall_ratio,top from
	 (select district,(visitors/estimated_population_2019) as footfall_ratio ,
     row_number() over(order by (visitors/estimated_population_2019) desc) as top, 
     row_number() over(order by (visitors/estimated_population_2019) ) as low 
     from cte ) subquery
where top<4					-- we only have 2 states with good footfall_ratio 
order by footfall_ratio desc;

/* 7 What will be the projected number of domestic and foreign tourists in Hyderabad in 2025
based on the growth rate from previous years
Insight Better estimate incoming tourists count so that government can plan the infrastructure better */

-- Estimated Domestic visitors 2025
 #creating cte for Hyderabad visitors for calculation
 
 with cte as(
  Select district,
sum(case when year = 2016 Then visitors else 0 End) as visitors_2016 ,   #all the visitors from 2016 district wise
sum(case when year = 2019 Then visitors else 0 End) as visitors_2019	 #all the visitors from 2019 district wise
from tourdata.domestic_visitors
group by district 
having district ="Hyderabad"
),
cte2 as(
 select visitors_2019 as dom_visitors_2019,(power((visitors_2019/visitors_2016),(1/3))-1)  as AGR from cte   #AGR -0.16
)

 #result
select dom_visitors_2019 , 
		dom_visitors_2019 *1200 as rev_dom_visitors_2019 ,
		round(dom_visitors_2019*power((1+AGR),6)) as dom_visitors_2025 ,
        round(dom_visitors_2019*power((1+AGR),6))*1200 as rev_dom_visitors_2025
from cte2; 

 -- Foreign Vistors by 2025
 
-- Projected visitors = Current visitors x (1 + Annual Growth Rate)^(Number of Years)
-- Annual Growth Rate = [(Ending Value / Beginning Value)^(1 / Number of Years)] - 1

#Calculation part
with cte as(
  Select district,
sum(case when year = 2016 Then visitors else 0 End) as visitors_2016 ,   #all the visitors from 2016 district wise
sum(case when year = 2019 Then visitors else 0 End) as visitors_2019	 #all the visitors from 2019 district wise
from tourdata.foreign_visitors
group by district 
having district ="Hyderabad"
),
cte2 as(
 select visitors_2019 as for_visitors_2019 ,(power((visitors_2019/visitors_2016),(1/3))-1)  as AGR from cte   #AGR =0.25
 )
 
 #result
select for_visitors_2019 ,
		for_visitors_2019 *5600 as rev_for_visitors_2019, 
		round(for_visitors_2019*power((1+0.25),6)) as for_visitors_2025 ,
        round(for_visitors_2019*power((1+0.25),6))*5600 as rev_for_visitors_2025
from cte2;     

select year, sum(visitors) as domestic_visitors 
from tourdata.domestic_visitors where year = 2019; 

Select  
sum(case when year = 2016 Then visitors else 0 End) as visitors_2016 ,   #all the visitors from 2016 district wise
sum(case when year = 2017 Then visitors else 0 End) as visitors_2017,
sum(case when year = 2018 Then visitors else 0 End) as visitors_2018,
sum(case when year = 2019 Then visitors else 0 End) as visitors_2019	 #all the visitors from 2019 district wise
from tourdata.domestic_visitors
group by district 
having district ="Hyderabad";

