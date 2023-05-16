--- Query 1:

--- 1. List down the top 10 districts that have the highest number of domestic visitors overall (2016 - 2019)?

select district, sum(visitors) as visitors 
from tourdata.dome_tour_file
group by district order by visitors desc limit 10;

--- Top 10 districts of foreign visitors

select district, sum(visitors) as visitors
from tourdata.foreign_tour_visitors
group by district 
order by visitors desc limit 10;

--- Query 2:
---  List down the top 3 districts based on Compounded annual growth rate (CAGR) of visitors between (2016 - 2019)?

-- CAGR = (Ending value(EV) / Begining value(BV))^(1 / no.of.years) - 1 , n = 2019-2016 = 3

--- Top 3 Domestic Visitors according to CAGR:

with cte as(
select district,
sum(case when year = 2016 then visitors else 0 end) as BV,
sum(case when year = 2019 then visitors else 0 end) as EV
from tourdata.dome_tour_file
group by district
)

select district, BV, EV, round((power((EV/BV), 1/3)-1)* 100, 2) AS CAGR
from cte 
order by CAGR desc limit 3;

----------------------------------------------------------------------------------------------------
--- Top 3 Foreign visitors according CAGR:

with cte as(
select district,
sum(case when year = 2016 then visitors else 0 end) as BV,
sum(case when year = 2019 then visitors else 0 end) as EV
from tourdata.foreign_tour_visitors
group by district
)

select district, BV, EV, round((power((EV/BV), 1/3)-1)* 100, 2) AS CAGR
from cte 
order by CAGR desc limit 3;

--- Query 3:-
--- List down the bottom 3 districts based on Compounded annual growth rate (CAGR) of visitors between (2016 - 2019)?

--- Bottom 3 Domestic Visitors according to CAGR:

with cte1 as(
select district,
sum(case when year = 2016 then visitors else 0 end) as BV,
sum(case when year = 2019 then visitors else 0 end) as EV
from tourdata.dome_tour_file
group by district
), 

cte2 as(
select district, BV, EV, round((power((EV/BV), 1/3)-1)*100, 2) AS CAGR
from cte1
)

select * from cte2
having CAGR is not NULL
order by CAGR limit 3;
 
--- Bottom 3 Foreign visitors according to CAGR:

with cte1 as(
select district,
sum(case when year = 2016 then visitors else 0 end) as BV,
sum(case when year = 2019 then visitors else 0 end) as EV
from tourdata.foreign_tour_visitors
group by district
), 

cte2 as(
select district, BV, EV, round((power((EV/BV), 1/3)-1)*100, 2) AS CAGR
from cte1
)

select * from cte2
having CAGR is not NULL
order by CAGR limit 3;

--- Query 4:
--- What are the peak and low season months for Hyderabad based on the data from 2016 to 2019 for Hyderabad district?

--- peak months for domestic visitors in Hyderabad
select month as peak_season, sum(visitors) as visitors 
from tourdata.dome_tour_file
where district = "Hyderabad"
group by month
order by visitors desc limit 5;

--- low months for domestic visitors in Hyderabad
select month as low_season, sum(visitors) as visitors 
from tourdata.dome_tour_file
where district = "Hyderabad"
group by month
order by visitors limit 5;

--- peak months for foreign visitors in Hyderabad
select month as peak_season, sum(visitors) as visitors
from tourdata.foreign_tour_visitors
where district = "Hyderabad"
group by month order by visitors desc limit 5;

--- low months for foreign visitors in Hyderabad
select month as low_season, sum(visitors) as visitors
from tourdata.foreign_tour_visitors
where district = "Hyderabad"
group by month order by visitors limit 5;

--- Query 5:-
--- Show the top and bottom 3 districts with high domestic to foreign tourist ratio?

----- Top districts:
 with cte as (
select D.district ,
 sum(D.visitors) as dom_visitor,sum(F.visitors) as frgn_visitor
from tourdata.dome_tour_file D
join tourdata.foreign_tour_visitors F
on D.district =F.district and D.month = F.month and D.year =F.year
group by D.district
)

select top_rank,district,dom_visitor,frgn_visitor,dom_frgn_ratio
from(select  * ,rank() over(order by dom_frgn_ratio) as top_rank ,rank() over(order by dom_frgn_ratio desc) as bottom_rank
		from (select * ,round(dom_visitor/frgn_visitor) as dom_frgn_ratio
				from cte) subquery
where dom_frgn_ratio is not null)subquery2  
where top_rank<4
order by top_rank;

----- bottom districts
with cte as (
select D.district ,
 sum(D.visitors) as dom_visitor,sum(F.visitors) as frgn_visitor
from tourdata.dome_tour_file D
join tourdata.foreign_tour_visitors F
on D.district =F.district and D.month = F.month and D.year =F.year
group by D.district
)

select bottom_rank,district,dom_visitor,frgn_visitor,dom_frgn_ratio
from(select  * ,rank() over(order by dom_frgn_ratio) as top_rank, rank() over(order by dom_frgn_ratio desc) as bottom_rank
		from (select * ,round(dom_visitor/frgn_visitor) as dom_frgn_ratio
				from cte) subquery
where dom_frgn_ratio is not null)subquery2  
where bottom_rank<4
order by bottom_rank;

--- Query 6:
--- list the top and bottom 5 districts based on 'population to tourist footfall ratio*' ratio in 2019?

/*
Total population in 2011	35,193,978	  			
Total population in 2023	38,090,000				
					
Increasing population = 2,896,022 = Total pop in 2023 - total pop in 2019			
					
Growth	0.08228743 = increasing population / total pop in 2019			
					
Yearly Growth Percentage = 0.748067545 = (0.7) percentage =  growth * 100 / years  = here years = 11 = difference between 2011 & 2023
			
Yearly Growth = 246358	  =  2011 population * 0.007			
					
Assume it gowing by 0.7%
					
Now the population of 2019 = 37164841 = total pop in 2011 + (8*yearly growth), here 8 because difference between 2011 and 2019			
Population of 2025 = 38642988 = total pop in 2011 + (14*yearly growth), here 14 because difference between 2011 and 2025		
*/

--- top_5 Domestic visitors
with cte as (
 select p.district,year,estimated_population_2019,sum(visitors) as visitors
 from tourdata.population_1 P
 join tourdata.dome_tour_file D
 on P.district =D.district
 where year =2019 
 group by p.district,estimated_population_2019,year)
 
 select top_5,district,footfall_ratio from
	 (select district,(visitors/estimated_population_2019) as footfall_ratio ,
     row_number() over(order by (visitors/estimated_population_2019) desc) as top_5, 
     row_number() over(order by (visitors/estimated_population_2019) ) as bottom_5
     from cte where visitors>0) subquery     
     where top_5<6
 order by footfall_ratio desc;
 
 ---- bottom 5 domestic visitors
with cte as (
 select p.district,year,estimated_population_2019,sum(visitors) as visitors
 from tourdata.population_1 P
 join tourdata.dome_tour_file D
 on P.district =D.district
 where year =2019 
 group by p.district,estimated_population_2019,year)
 
 select bottom_5,district,footfall_ratio from
	 (select district,(visitors/estimated_population_2019) as footfall_ratio ,
     row_number() over(order by (visitors/estimated_population_2019) desc) as top_5, 
     row_number() over(order by (visitors/estimated_population_2019) ) as bottom_5
     from cte where visitors>0) subquery     
     where bottom_5<6
 order by footfall_ratio ;
 
 --- top 5 foreign visitors
 with cte as (
 select p.district,year,estimated_population_2019,sum(visitors) as visitors
 from tourdata.population_1 P
 join tourdata.foreign_tour_visitors F
 on P.district =F.district
 where year =2019
 group by p.district,estimated_population_2019,year)
select top_5,district,footfall_ratio from
	 (select district,(visitors/estimated_population_2019) as footfall_ratio ,
     row_number() over(order by (visitors/estimated_population_2019) desc) as top_5, 
     row_number() over(order by (visitors/estimated_population_2019) ) as bottom_5
     from cte ) subquery
where top_5<3    # it has only two values					
order by footfall_ratio desc;

-------------------------------------------------------------------------------------------------------
