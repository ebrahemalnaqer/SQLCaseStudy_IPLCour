use ipl_analytics;
select * from iplplayers;

-- 	Q1 Find the total spending on players for each team :
select Team, sum(Price_in_cr) As 'Total spending'
from iplplayers
group by team
order by 'Total spending' desc;

-- Q2 Find the top 3 highest-paid 'All-rounders' across all teams:

SELECT Player, Price_in_cr,Team
FROM IPLPlayers
WHERE Role = 'All-rounder'
ORDER BY Price_in_cr DESC
LIMIT 3;


-- Q3 Find the highest-priced player in each team:
select p.team,p.player,p.price_in_cr
from iplplayers p
-- In SQL, the default JOIN type is INNER JOIN. This means if you don't explicitly specify the type of JOIN, the server automatically assumes you mean an inner join, which requires a perfect match between the two tables.
join(
SELECT Team, MAX(Price_in_cr) AS MaxPrice
FROM IPLPlayers
GROUP BY Team
)As sub 
ON p.Team = sub.Team AND p.Price_in_cr = sub.MaxPrice;

-- Q4 Rank player by their price whitin each team and list the 2 top for every team:

with RankedPlayers AS (
select Player,Team,Price_in_cr, 
ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankWithinTeam
from iplplayers
)
select Player,Team,Price_in_cr, RankWithinTeam 
from RankedPlayers 
where RankWithinTeam <= 2 ;

-- Q5 FIND the most expensive player from each team, along with the secomd-most expensive players name and price:

with RankedPlayers AS (
select Player,Team,Price_in_cr, 
ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankWithinTeam
from iplplayers
)

select team,
MAX(CASE WHEN RankWithinTeam = 1 THEN Player END) AS MostExpensivePlayer,
MAX(CASE WHEN RankWithinTeam = 1 THEN Price_in_cr END) AS HighestPrice,
MAX(CASE WHEN RankWithinTeam = 2 THEN Player END) AS SecondMostExpensivePlayer,
MAX(CASE WHEN RankWithinTeam = 2 THEN Price_in_cr END) AS SecondHighestPrice
from RankedPlayers
group by team;

-- Q6 Calculate the percentage contribution of each players price to their team total spending:

select player, team,Price_in_cr,
cast(Price_in_cr/ (sum(Price_in_cr) over (partition by team)) * 100 AS decimal(10,2)) as contribution
from iplplayers;

-- Q7 Classify players as 'High', 'Medium', or 'Low' priced based on the following rules:
-- High: Price > 15 crore
-- Medium: Price between 5 crore and 15 crore
-- Low: Price < 5 crore
-- and find out the number of players in each bracket

with CTE_RB AS(
select team,Player,Price_in_cr ,
case
when Price_in_cr >= 15 then 'high'
when Price_in_cr between 5 and 15 then 'Midum'
else 'Low'
end as priceCategory
from iplplayers
)
select team , priceCategory,count(*) AS 'noOfPlayers'
from  CTE_RB 
group by  team , priceCategory
order by  team , priceCategory;


-- Q8 Find the average price of Indian players and compare it with overseas players using a subquery:
-- الجزء الأول: حساب متوسط أسعار اللاعبين الهنود
-- الجزء الأول: حساب متوسط أسعار اللاعبين الهنود والتقريب لرقمن بعد النقطة
SELECT 
    'Indian' AS PlayerType,
    (SELECT ROUND(AVG(Price_in_cr), 2) FROM IPLPlayers WHERE Type LIKE 'Indian%') AS AvgPrice

UNION ALL

-- الجزء الثاني: حساب متوسط أسعار اللاعبين الأجانب والتقريب لرقمن بعد النقطة
SELECT 
    'Overseas' AS PlayerType,
    (SELECT ROUND(AVG(Price_in_cr), 2) FROM IPLPlayers WHERE Type LIKE 'Overseas%') AS AvgPrice;
    
    
-- Q9 Identify players who earn more than the average price of their team:
SELECT Player, Team, Price_in_cr
FROM IPLPlayers p
WHERE Price_in_cr > (
    SELECT AVG(Price_in_cr)
    FROM IPLPlayers
    WHERE Team = p.Team
);


-- Q10 For each role, find the most expensive player and their price using a correlated subquery
SELECT Player, Team, Role, Price_in_cr
FROM IPLPlayers p
WHERE Price_in_cr = (
    SELECT MAX(Price_in_cr)
    FROM IPLPlayers
    WHERE Role = p.Role
);    