--Merging tables 

CREATE TABLE appliedWE AS 
SELECT DISTINCT atbat.batter_name AS batter,
       atbat.pitcher_name AS pitcher,
       p.des AS des,
       p.pitch_type AS pitch_type,
       atbat.p_throws AS p_throws,
       atbat.stand AS b_stands,
       p.type AS result,
       p.inning_side AS side,
       p.inning AS inn,
       substr(p.count,1,1) AS b,
       substr(p.count,3,4) AS s,
       atbat.o AS out,
       p.Occupied1b AS state_1b,
       p.Occupied2b AS state_2b,
       p.Occupied3b AS state_3b,
       p.zone AS zone,
       (CAST(atbat.home_team_runs AS INT) - CAST(atbat.away_team_runs AS INT) ) AS rd,
       atbat.off_rem_outs_h AS off_r_outs,
       atbat.def_rem_outs_h AS def_r_outs,
       p.num AS num,
       p.gameday_link AS gameday_link,
       p.tfs_zulu AS time,
       atbat.event AS end_of_AB,
       atbat.score AS scoring_play
  FROM pitch AS p
       INNER JOIN
       atbat ON (p.gameday_link = atbat.gameday_link AND 
                 p.num = atbat.num) 
       INNER JOIN
       game ON atbat.gameday_link = game.gameday_link        
    ORDER BY game.gameday_link ASC,
              p.num ASC,
              p.tfs_zulu ASC;


DELETE FROM appliedWE
WHERE CAST(substr(time,1,4) AS INT) < 2014 OR time IS NULL;


ALTER TABLE appliedWE
ADD rownum
DEFAULT _ROWID_;

UPDATE appliedWE
SET rownum = (_ROWID_ - 2858233);