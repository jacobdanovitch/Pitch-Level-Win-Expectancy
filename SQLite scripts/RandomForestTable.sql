CREATE TABLE Random_Forest AS 
SELECT DISTINCT p.inning_side AS side,
       p.inning AS inn,
       substr(p.count,1,1) AS b,
       substr(p.count,3,4) AS s,
       atbat.o AS out,
       p.Occupied1b AS state_1b,
       p.Occupied2b AS state_2b,
       p.Occupied3b AS state_3b,
       (CAST(atbat.home_team_runs AS INT) - CAST(atbat.away_team_runs AS INT)) AS rd,
       game.homeW AS home_Result,
       atbat.off_rem_outs_h AS off_r_outs,
       atbat.def_rem_outs_h AS def_r_outs,
       atbat.gameday_link AS gameday_link
  FROM pitch AS p
       INNER JOIN
       atbat ON (p.gameday_link = atbat.gameday_link AND 
                 p.num = atbat.num) 
       INNER JOIN
       game ON atbat.gameday_link = game.gameday_link
       --WHERE atbat.gameday_link = "gid_2010_04_02_chamlb_atlmlb_1"