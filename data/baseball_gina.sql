--First page
--1). What range of years for baseball games played does the provided database cover? 1871-2016
SELECT min(yearid) AS first_year, max(yearid) AS latest_year
FROM teams;

--2). Find the name and height of the shortest player in the database. 
--How many games did he play in? What is the name of the team for which he played:
--Eddie Gaedel at 43 inches (3.53 feet)
--One game for the St. Louis Browns

SELECT concat(namefirst,' ',namelast) AS full_name, height, name AS team, g_all as total_game
FROM people  INNER JOIN appearances USING (playerid)
			  INNER JOIN teams USING(teamid, yearid)
			  WHERE height = (SELECT min(height) FROM people)

--3).Find all players in the database who played at Vanderbilt University.
--Create a list showing each player’s first and last names as well as 
--the total salary they earned in the major leagues.  Sort this list 
--in descending order by the total salary earned. Which Vanderbilt player 
--earned the most money in the majors?  David Price

SELECT namefirst, namelast, SUM(salary)::numeric::money AS total_salary
FROM people INNER JOIN salaries USING (playerid)
WHERE playerid IN (SELECT playerid
				FROM collegeplaying INNER JOIN schools USING(schoolid)
				WHERE schoolname LIKE 'Vande%')
GROUP BY namefirst, namelast
order by total_salary desc;

--4. Using the fielding table, group players into three groups
---based on their position: label players with position OF as "Outfield",
---those with position "SS", "1B", "2B", and "3B" as "Infield", and
---those with position "P" or "C" as "Battery". Determine the number 
---of putouts made by each of these three groups in 2016.


SELECT sum(CASE WHEN pos = 'OF' THEN po END) AS outfield_po,
	   sum(CASE WHEN pos in ('ss','1B','2B','3B') THEN po END) AS infield_po,  
	   sum(CASE WHEN pos in ('P','C') THEN PO END) AS battery_putouts
FROM fielding
WHERE yearid = 2016;

--5). Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
--Overall both are increasing over time

WITH decades AS (SELECT CONCAT((yearid/10 * 10)::text, '''s') AS decade, *
					FROM teams)

SELECT decade, ROUND(SUM(so)::numeric/(SUM(g)/2),2) AS avg_so,
				ROUND(SUM(hr)::numeric/(SUM(g)/2),2) AS avg_hr
FROM decades
GROUP BY decade
ORDER BY decade


--QUESTION #6: Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful.
--Chris Owings 91.3%
SELECT namefirst, namelast, sb, cs,yearid,
		CASE WHEN sb+cs = 0 THEN 0
			ELSE ROUND((sb::decimal/(sb+cs)*100),2)
				END AS sb_success_rate
FROM people
INNER JOIN Batting
USING(playerid)
WHERE yearid = 2016 AND (sb+cs) >= 20
ORDER BY sb_success_rate DESC
LIMIT 10;

--7a).From 1970 – 2016, what is the largest number of wins for a team that did not 
--win the world series? What is the smallest number of wins for a team that did win 
--the world series? Doing this will probably result in an unusually small number of 
--wins for a world series champion – determine why this is the case. Then redo your 
--query, excluding the problem year.
--ANSWER: least wins LA Dodgers at 63, Most wins Seatle Mariners; 116
--The low total of least wins including a world sereis was most likely due to a baseball strike occuring
--in 1981, which changes the result to St Louis Cardinals at 83 wins. 25% of the time, did a team 
--win both the series and have the most wins.
--7b).How often from 1970 – 2016 was it the case that
--a team with the most wins also won the world series? What percentage of the time?


SELECT name, yearid, MAX(w) AS most_wins
FROM teams
WHERE yearid between 1970 and 2016 AND WSwin = 'N'
GROUP BY yearid, name
ORDER BY max(w)DESC
Limit 1;

SELECT COUNT(yearid) AS year, yearid, name, MIN(w) AS least_wins
FROM teams
WHERE yearid between 1970 and 2016 AND wswin = 'Y' 
GROUP BY yearid, name
ORDER BY least_wins
LIMIT 1;

SELECT COUNT(yearid) AS year, yearid, name, MIN(w) AS least_wins
FROM teams
WHERE yearid between 1970 and 2016 AND wswin = 'Y' AND yearid <> '1981'
GROUP BY yearid, name
ORDER BY least_wins;

--Part B)
WITH world_series_winners AS
	(SELECT yearid, MAX(w) AS most_wins
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid)

SELECT COUNT (*)
FROM world_series_winners INNER JOIN teams	USING (yearid)
WHERE wswin = 'Y' AND w = most_wins;
--B2)														
WITH world_series_winners AS
	(SELECT yearid, MAX(w) AS most_wins
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid)

SELECT AVG(CASE when w= most_wins THEN 1 ELSE 0 END)*100 AS pct
FROM world_series_winners INNER JOIN teams	USING (yearid)
WHERE wswin = 'Y';

--8).Using the attendance figures from the homegames table, 
--find the teams and parks which had the top 5 average attendance 
--per game in 2016 (where average attendance is defined as total 
--attendance divided by number of games). Only consider parks where 
--there were at least 10 games played. Report the park name, team
--name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT park_name,name AS team_name,(h.attendance/h.games) AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p USING(park)
INNER JOIN teams AS t ON t.teamid = h.team
WHERE games >=10 AND year = 2016
GROUP BY park_name,name,avg_attendance
ORDER BY avg_attendance DESC
LIMIT 5;
--LOWEST 5
SELECT park_name,name AS team_name,(h.attendance/h.games) AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p USING(park)
INNER JOIN teams AS t ON t.teamid = h.team
WHERE games >=10 AND year = 2016
GROUP BY park_name,name,avg_attendance
ORDER BY avg_attendance ASC
LIMIT 5;

--9).Which managers have won the TSN Manager of the Year award in both the National League (NL)
---and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT *
FROM awardsmanagers
WHERE awardid LIKE 'TSN%' AND lgid IN ('AL', 'NL');


SELECT playerid, namefirst, namelast, 
teams.name AS team_name
FROM awardsmanagers
INNER JOIN people
	USING(playerid)
INNER JOIN teams
		ON awardsmanagers.yearid = teams.yearid
WHERE awardid = 'TSN Manager of the Year'
			AND awardsmanagers.lgid IN ('AL','NL')
GROUP BY playerid, namefirst, namelast, team_name
HAVING COUNT(DISTINCT awardsmanagers.lgid) = 2;

--Q10). Find all players who hit their career highest number of home runs in 2016. 
--Consider only players who have played in the league for at least 10 years, and who 
--hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016. 

WITH ten_year_players AS (SELECT namefirst, namelast, yearid, hr,debut,finalgame
	FROM people AS p
	INNER JOIN batting AS b USING(playerid)
	WHERE EXTRACT(day from finalgame::timestamp - debut::timestamp) >=3650)

SELECT namefirst, namelast, yearid, MAX(hr) AS career_highest
FROM ten_year_players
WHERE yearid = 2016 and hr>=1
GROUP BY namefirst,namelast,yearid,debut,finalgame;

			

