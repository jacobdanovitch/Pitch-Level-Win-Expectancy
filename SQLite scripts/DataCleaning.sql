--Cleaning outs, runs

--------------------------------------------------CLEANING OUTS---------------------------------------------------

ALTER TABLE appliedWE
ADD out_on_play
DEFAULT NULL;

UPDATE appliedWE
SET out_on_play = CASE
WHEN end_of_AB IN ("Flyout", "Groundout", "Pop Out", "Strikeout", "Lineout", "Bunt Groundout",	"Runner Out", "Forceout", "Sac Fly"," Sac Bunt", "Fielders Choice Out", "Bunt Pop Out", "Batter Interference", "Fielders Choice", "Bunt Lineout")
THEN 1
WHEN end_of_AB IN ("Grounded Into DP", "Double Play", "Strikeout - DP", "Sac Fly DP", "Sacrifice Bunt DP")
THEN 2
WHEN end_of_AB == "Triple Play"
THEN 3
ELSE 0
END;


--------------------------------------------------CLEANING RUNS----------------------------------------------------------------------------

CREATE TABLE aw2 AS 
SELECT * FROM appliedWE;

UPDATE appliedWE
SET rd = (SELECT rd 
        FROM aw2
        WHERE ((aw2.rownum+1) == appliedWE.rownum)
        ORDER BY rownum DESC)
WHERE scoring_play == "T";

DROP TABLE aw2; 

--SQLite has serious problems w/ creating temp tables 

-----------------------------------------------------------------
