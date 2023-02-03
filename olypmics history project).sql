

select * from PortfolioProject1..athlete_events;

select count(1) from PortfolioProject1..athlete_events;


--The number of Olypmic Games held.

select count(distinct Games) as total_olympic_games
    from PortfolioProject1..athlete_events;

--The list of all Olympics games held so far.

select distinct Games as total_olympic_games
    from PortfolioProject1..athlete_events;

--The total no of nations who participated in each olympics game.

select count( distinct NOC) as total_nations, Games 
    from PortfolioProject1..athlete_events
	group by games
	order by games;

--The year that saw the highest and lowest no of countries participating in olympics.

with no_countries (NOC_count, year)
as 
(select count(distinct NOC) as NOC_count, year
    from PortfolioProject1..athlete_events
	group by year
)
select  NOC_count, year from no_countries
where NOC_count = (select min(NOC_count) from no_countries)
;

with no_countries (NOC_count, year)
as 
(select count(distinct NOC) as NOC_count, year
    from PortfolioProject1..athlete_events
	group by year
)
select  NOC_count, year from no_countries
where NOC_count = (select max(NOC_count) from no_countries)
;

--The nation that has participated in all of the olympic games.

      with tot_games as
              (select count(distinct games) as total_games
              from PortfolioProject1..athlete_events),
          countries as
              (select games, nr.region as country
              from PortfolioProject1..athlete_events oh
              join PortfolioProject1..noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1;
	
--The sport which was played in all summer olympics.

select year, sport, season from PortfolioProject1..athlete_events
where season = 'Summer'
order by year;

with sport_count as (
select count(distinct year) as total_year from PortfolioProject1..athlete_events where season = 'Summer'), 
 sport_type as (
select sport, count(distinct year) as year_total from PortfolioProject1..athlete_events  where season = 'Summer' group by sport)
select * from sport_count join sport_type on total_year =year_total;

-- The Sports that were played only once in the olympics.

with sport_type as (
select sport,  count(distinct year) as year_total from PortfolioProject1..athlete_events group by sport)
select * from sport_type where year_total = 1
order by sport;

--The total number of sports played in each olympic games.

select games, count(distinct sport) as total_sports 
    from PortfolioProject1..athlete_events
	group by games
	order by total_sports desc;

--The information about the oldest athletes to win a gold medal.
with data as (
select name, sex, age, team, games, city, sport, event, medal from PortfolioProject1..athlete_events
where medal = 'Gold'),
 ranking as ( 
 select *, rank() over(order by age desc) as rnk
            from data
            where medal='Gold')
 select *
    from ranking
    where rnk = 1;


--The Ratio of male and female athletes who participated in all olympic games.
with female_number as (select sex, count(sex) as F_n
from PortfolioProject1..athlete_events
where sex= 'F'
group by sex),
male_number as (
select sex, count(sex) as M_n
from PortfolioProject1..athlete_events
where sex= 'M'
group by sex)
select round(M_n/F_n, 2) as ratio
  from female_number, male_number;


-- The top 5 athletes who have won the most gold medals.

with data as (select name, count(medal) as count_gold
from PortfolioProject1..athlete_events 
where medal = 'Gold'
group by name),
ranking as ( 
 select *, rank() over(order by count_gold desc) as rnk
            from data)
 select *
    from ranking
    where rnk <6;

--The top 5 athletes who have won the most medals (gold/silver/bronze).

with data as (select name, count(medal) as count_medal
from PortfolioProject1..athlete_events 
where medal = 'Gold'or medal = 'Silver'or medal = 'Bronze' 
group by name),
ranking as ( 
 select *, rank() over(order by count_medal desc) as rnk
            from data)
 select *
    from ranking
    where rnk <6;


--The top 5 most successful countries in olympics. Success is defined by no of medals won.
with data as (select NOC, count(medal) as count_medal
from PortfolioProject1..athlete_events 
where medal = 'Gold'or medal = 'Silver'or medal = 'Bronze' 
group by NOC),
ranking as ( 
 select *, rank() over(order by count_medal desc) as rnk
            from data)
 select *
    from ranking
    where rnk <6;


--The list of total gold, silver and broze medals won by each country.
with medal_gold as (select NOC, count(medal) as gold_medal
from PortfolioProject1..athlete_events 
where medal = 'Gold' 
group by NOC),
medal_silver as (select NOC, count(medal) as silver_medal
from PortfolioProject1..athlete_events 
where medal = 'Silver'
group by NOC),

medal_bronze as (select NOC, count(medal) as bronze_medal
from PortfolioProject1..athlete_events 
where medal = 'Bronze'
group by NOC)

select medal_gold.NOC, gold_medal, silver_medal, bronze_medal from medal_gold join medal_silver on medal_gold.NOC = medal_silver.NOC 
join medal_bronze on medal_gold.NOC = medal_bronze.NOC
order by gold_medal desc;

--The list of total gold, silver and broze medals won by each country corresponding to each olympic games.

with total_gold_1 as
(SELECT concat(games, ' ', nr.region) as games
                , medal
                , count(1) as total_gold
                FROM PortfolioProject1..athlete_events oh
                JOIN PortfolioProject1..noc_regions nr ON nr.noc = oh.noc
                where medal = 'Gold'
                GROUP BY games,nr.region,medal
                ),


total_silver_1 as
(SELECT concat(games, ' ', nr.region) as games
                , medal
                , count(1) as total_silver
                FROM PortfolioProject1..athlete_events oh
                JOIN PortfolioProject1..noc_regions nr ON nr.noc = oh.noc
                where medal = 'Silver'
                GROUP BY games,nr.region,medal
                ),

total_bronze_1 as
(SELECT concat(games, ' ', nr.region) as games
                , medal
                , count(1) as total_bronze
                FROM PortfolioProject1..athlete_events oh
                JOIN PortfolioProject1..noc_regions nr ON nr.noc = oh.noc
                where medal = 'Bronze'
                GROUP BY games,nr.region,medal
                )
select total_gold_1.games, total_gold, total_silver, total_bronze from total_gold_1 
join total_silver_1 on total_gold_1.games= total_silver_1.games
join total_bronze_1 on total_gold_1.games= total_bronze_1.games
order by total_gold_1.games, total_gold;

--The country that won the most gold, most silver and most bronze medals in each olympic games.

with total_gold_1 as
(SELECT concat(games, ' - ', nr.region) as games
                , medal
                , count(1) as total_gold
                FROM PortfolioProject1..athlete_events oh
                JOIN PortfolioProject1..noc_regions nr ON nr.noc = oh.noc
                where medal = 'Gold'
                GROUP BY games,nr.region,medal
                ),


total_silver_1 as
(SELECT concat(games, ' - ', nr.region) as games
                , medal
                , count(1) as total_silver
                FROM PortfolioProject1..athlete_events oh
                JOIN PortfolioProject1..noc_regions nr ON nr.noc = oh.noc
                where medal = 'Silver'
                GROUP BY games,nr.region,medal
                ),

total_bronze_1 as
(SELECT concat(games, ' - ', nr.region) as games
                , medal
                , count(1) as total_bronze
                FROM PortfolioProject1..athlete_events oh
                JOIN PortfolioProject1..noc_regions nr ON nr.noc = oh.noc
                where medal = 'Bronze'
                GROUP BY games,nr.region,medal
                )
select total_gold_1.games, total_gold, total_silver, total_bronze from total_gold_1 
join total_silver_1 on total_gold_1.games= total_silver_1.games
join total_bronze_1 on total_gold_1.games= total_bronze_1.games
order by total_gold_1.games, total_gold;

 select distinct games
    	, concat(first_value(country) over(partition by games order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
    	, concat(first_value(country) over(partition by games order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
    	, concat(first_value(country) over(partition by games order by bronze desc)
    			, ' - '
    			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
    from temp
    order by games;











