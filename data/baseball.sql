--First page
--1). What range of years for baseball games played does the provided database cover? 1871-2016
SELECT min(yearid) AS first_year, max(yearid) AS latest_year
FROM teams;

--2). Find the name and height of the shortest player in the database. Eddie Gaedel at 43 inches (3.53 feet)
--How many games did he play in? What is the name of the team for which he played: One game for the St. Louis Browns
SELECT *
FROM people;

SELECT  playerid, namelast, namefirst, height::integer
FROM people
ORDER BY height::integer;

SELECT namelast, finalgame, debut 
FROM people
WHERE namelast = 'Gaedel';

SELECT teamid, playerid, g_all
FROM people
INNER JOIN appearances
USING (playerid)
WHERE playerid = 'gaedeed01';

--3).Find all players in the database who played at Vanderbilt University.
-----Create a list showing each player’s first and last names as well as 
-----the total salary they earned in the major leagues.  Sort this list 
-----in descending order by the total salary earned. Which Vanderbilt player 
-----earned the most money in the majors?  David Price

SELECT DISTINCT playerid, schoolid, namelast, namefirst, SUM(salary::numeric::money) AS total_salary
FROM collegeplaying
LEFT JOIN people
USING(playerid)
INNER JOIN salaries
USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY playerid, schoolid, namelast, namefirst
ORDER BY total_salary desc;

--7).From 1970 – 2016, what is the largest number of wins for a team that did not 
--win the world series? What is the smallest number of wins for a team that did win 
--the world series? Doing this will probably result in an unusually small number of 
--wins for a world series champion – determine why this is the case. Then redo your 
--query, excluding the problem year. How often from 1970 – 2016 was it the case that
--a team with the most wins also won the world series? What percentage of the time?

SELECT *
FROM teams;

SELECT yearid, name, teamid, w
FROM teams;

SELECT yearid, name, teamid, MAX(w) AS most_wins
FROM teams
WHERE yearid between 1970 and 2016
GROUP BY yearid,name,teamid
ORDER BY most_wins DESC;

SELECT yearid, name, teamid, MAX(w) AS most_wins
FROM teams
WHERE yearid between 1970 and 2016 and wswin IS NOT 'Y' and wswin IS NOT 'null'
GROUP BY yearid,name,teamid
ORDER BY most_wins DESC;




