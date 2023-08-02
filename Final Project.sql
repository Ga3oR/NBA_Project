## DATABASE CREATION ##

Create database nba;
Use nba;

## TABLES CREATION ##

# Table: TEAMS
Create table Teams (
id INT PRIMARY KEY NOT NULL,
name varchar(25) UNIQUE NOT NULL,
arena varchar (50) NOT NULL,
conference varchar(7));

# Table: PLAYERS
Create table Players (
id INT PRIMARY KEY NOT NULL,
team_id INT NOT NULL,
full_name varchar(40) UNIQUE NOT NULL,
number INT,
height decimal (3,2) NOT NULL,
country varchar(15) NOT NULL,
age INT NOT NULL,
birthdate date NOT NULL,
experience INT NOT NULL,
FOREIGN KEY (team_id) REFERENCES Teams(id) ON DELETE CASCADE);

# Table: SERIES
Create table Series (
id INT PRIMARY KEY NOT NULL,
team1_id INT NOT NULL,
team2_id INT NOT NULL,
round INT NOT NULL,
team1_score INT NOT NULL,
team2_score INT NOT NULL,
CONSTRAINT team_unique UNIQUE (team1_id, team2_id),   
CONSTRAINT different_team CHECK (team1_id != team2_id), 
FOREIGN KEY (team1_id) REFERENCES Teams(id) ON DELETE CASCADE,
FOREIGN KEY (team2_id) REFERENCES Teams(id) ON DELETE CASCADE);

# Table: GAMES
Create table Games (
id INT PRIMARY KEY NOT NULL,
series_id INT NOT NULL,
arena varchar(50) NOT NULL,
date datetime NOT NULL,
team1_score INT NOT NULL, 
team2_score INT NOT NULL,
FOREIGN KEY (series_id) REFERENCES Series(id) ON DELETE CASCADE);

# Table: PLAYERSTATS
Create table PlayerStats (
id INT PRIMARY KEY NOT NULL,
player_id INT NOT NULL,
game_id INT NOT NULL,
sec INT NOT NULL,
fgm INT NOT NULL,
fga INT NOT NULL,
fg_rate decimal (5,2) NOT NULL,
3pm INT NOT NULL,
3pa INT NOT NULL,
3p_rate decimal (5,2) NOT NULL,
ftm INT NOT NULL,
fta INT NOT NULL,
ft_rate decimal (5,2) NOT NULL,
oreb INT NOT NULL,
dreb INT NOT NULL,
reb INT NOT NULL,
ast INT NOT NULL,
stl INT NOT NULL,
blk INT NOT NULL,
tov INT NOT NULL,
pf INT NOT NULL,
pts INT NOT NULL,
FOREIGN KEY (player_id) REFERENCES Players(id) ON DELETE CASCADE,
FOREIGN KEY (game_id) REFERENCES Games(id) ON DELETE CASCADE);

# Table: ROLES
Create table Roles (
id char(1) PRIMARY KEY NOT NULL,
role varchar(15));

Insert into Roles
Values ('C','Center'), ('G', 'Guard'), ('F', 'Forward');

# Table: PLAYERROLEASSOCIATION
Create table PlayerRoleAssociation (        
id INT PRIMARY KEY NOT NULL, 
player_id INT NOT NULL,
role char(1) NOT NULL,
FOREIGN KEY (player_id) REFERENCES Players(id) ON DELETE CASCADE,                  
FOREIGN KEY (role) REFERENCES Roles(id)ON DELETE CASCADE);  

Select * from Teams;
Select * from Series;
Select * from Roles;
Select * from PlayerRoleAssociation;
Select * from Games;
Select * from Players;
Select * from PlayerStats;

## QUERIES examples ##
# All teams in NBA
select name from teams
;

# What dates was the final?
select games.date, series.round
from games, series
where series.id = games.series_id 
	and round = 4
order by date
;

# Which teams got to the finals? (round = 4)
select teams.name, teams.id
from teams
JOIN series ON series.team1_id = teams.id or series.team2_id = teams.id
where round = 4
;

# Which team won?
select distinct team1_id, team1_score, team2_score, team2_id
from teams
JOIN series ON series.team1_id = teams.id or series.team2_id = teams.id
where round = 4
;

# What is the name of the team?
select teams.name 
from teams
where teams.id = 21
;

# (Just for display)
select distinct team1_score as Golden_State_Warriors, team2_score as Boston_Celtics
from teams
JOIN series ON series.team1_id = teams.id or series.team2_id = teams.id
where round = 4
;

# Which players got to the final? (round = 4) And how many years of experience do they have?
select full_name as player , teams.name as team, experience
from players 
JOIN teams ON teams.id = players.team_id
where players.team_id IN (
	select teams.id 
	from teams
	JOIN series ON series.team1_id = teams.id or series.team2_id = teams.id
	where round = 4)
group by full_name
order by experience DESC
;

# What are the stats of players in Golden State Warriors' roaster?
select full_name as player, avg(fg_rate) as 2p_rate, avg(3p_rate) as 3p_rate, sum(pts) as tot_pts, sum(ast) as tot_ast
from players
JOIN playerstats ON players.id = playerStats.player_id
JOIN teams ON teams.id = players.team_id
where teams.name = 'Golden State Warriors'
group by full_name
order by tot_pts DESC
;

# How many roles there are, roughly?
select roles.role from roles;

# What are the stats of the FORWARDS in Golden State Warrior' roaster?
select  full_name, teams.name as team, role, avg(fg_rate) as fg_rate, avg(3p_rate) as 3p_rate, sum(pts) as tot_pts, sum(ast) as tot_ast
from players
JOIN playerstats ON players.id = playerStats.player_id
JOIN teams ON teams.id = players.team_id
JOIN playerroleassociation ON playerroleassociation.id = players.id
where teams.name = 'Golden State Warriors' 
	and playerroleassociation.role = 'F'
group by full_name
order by tot_pts DESC
;

# Who is the forward with the most blocks in Golden State Warrior' roaster?
select full_name as player, playerroleassociation.role, sum(blk) as blocks
from players
JOIN playerroleassociation ON players.id = playerroleassociation.player_id
JOIN playerstats ON playerstats.player_id = players.id
JOIN teams ON teams.id = players.team_id
where playerroleassociation.role = 'F' 
	and teams.name = 'Golden State Warriors'
group by full_name
order by blocks DESC
limit 1
;

# How did Wiggins do compared to all the other forwards in the playoff?
select full_name as player, teams.name as team, playerroleassociation.role, sum(blk) as blocks
from players
JOIN playerroleassociation ON players.id = playerroleassociation.player_id
JOIN playerstats ON playerstats.player_id = players.id
JOIN teams ON teams.id = players.team_id
where playerroleassociation.role = 'F' 
group by full_name
order by blocks DESC
;

# Who is the forwards with the highest 3 points rate in Boston Celtics' roaster?
select full_name as player, playerroleassociation.role, avg(3p_rate) as 3p_ratio
from players
JOIN playerroleassociation ON players.id = playerroleassociation.player_id
JOIN playerstats ON playerstats.player_id = players.id
JOIN teams ON teams.id = players.team_id
where playerroleassociation.role = 'F' 
	and teams.name = 'Boston Celtics'
group by full_name
order by 3p_ratio DESC
limit 1
;

# How did Gallinari do compared to all the other forwards in the playoff?
select full_name as player, teams.name as team, playerroleassociation.role, avg(3p_rate) as 3p_ratio
from players
JOIN playerroleassociation ON players.id = playerroleassociation.player_id
JOIN playerstats ON playerstats.player_id = players.id
JOIN teams ON teams.id = players.team_id
where playerroleassociation.role = 'F' 
group by full_name
order by 3p_ratio DESC
;

# We saw that gallinari has 13 years of experience. So:
# How did Gallinari do compared to the average of every player with the same (or more) years of experience?
select avg(3p_rate) as avg_pts
from playerstats
where playerstats.player_id in (
	select count(player_id)
	from players
	where experience>=13)
;

## 
# How many games have each player played? 
select players.full_name, count(playerstats.game_id) as tot_games
from players, playerstats
where players.id=playerstats.game_id
group by full_name
order by tot_games DESC
;

# How many baskets, assits, and turnovers did every player make?
select full_name, teams.name as team, sum(fgm) as 2pm, sum(3pm) as 3pm, sum(ast) as assists, sum(tov) as turnovers
from players
JOIN playerstats on players.id=PlayerStats.player_id
JOIN teams on teams.id = players.team_id
group by full_name
order by 3pm DESC
;

# How many assists compared to turnovers did a player make when he had more than 100assists?
with X as (
			select players.full_name, sum(ast) as assists, sum(tov) as turnovers
            from players
				join playerstats on players.id = playerstats.player_id
                group by full_name)
select X.full_name, assists, turnovers
from X
where assists>100
order by turnovers
;

# How many players are there for each nationality?
select country, count(country) as n
from players
group by country
order by n DESC
;

# There are 161 players from USA. We are know interested in their pshysical attributes.
select full_name as player, conference, country, age, height
from players
JOIN teams ON teams.id = players.team_id
where players.country = 'USA'
group by full_name
order by height desc
;

# We are now interested in the 5 tallest players who are NOT from USA.
select full_name, country, height
from players
where country not in ('USA')
order by height DESC
LIMIT 5
;

# Which players have played in an arena who has 'Cen' in his name?
select distinct full_name, arena
from players, playerstats, games
where players.id = playerstats.player_id 
	and playerstats.player_id = games.id 
		and arena LIKE '%Cen%'
order by arena
;
        
# Which is the arena that had the highest number of fouls?
select arena, sum(pf) as total_fouls
from games
INNER JOIN playerstats ON playerstats.game_id = games.id
group by arena
order by total_fouls DESC
limit 1
;
