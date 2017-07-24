#libraries

library(dplyr)
library(RSQLite)
library(pitchRx)


#pF/X db

my_db = dbConnect(SQLite(), dbname = "PlsPitchF_X.sqlite3")
initExtension(my_db)



updateScore <- dbSendQuery(
  my_db,
  sql(
    "WITH RECURSIVE thing(home_team_runs) AS (
    SELECT home_team_runs
    FROM atbat
    ORDER BY gameday_link ASC, num ASC
  )
    UPDATE atbat
    SET home_team_runs = (@n == COALESCE(home_team_runs, @n))"
)
)


ABquery <- dbSendQuery(my_db,
                       sql("SELECT *
                           FROM atbat  
                           ORDER BY gameday_link ASC, num ASC"))
atbats <- dbFetch(ABquery, n=50)


Pquery <- dbSendQuery(my_db,
                      sql("SELECT *
                          FROM pitch
                          WHERE CAST(substr(gameday_link,5,9) AS INT) > 2010
                          AND CAST(substr(gameday_link,10,11) AS INT) BETWEEN 4 AND 9"))
pitches <- dbFetch(Pquery, n=-1)
initExtension(results_db)
#dbGetQuery(results_db, sql("UPDATE game
#                            SET gameday_link = 'gid_' || gameday_link"))
gquery <- dbSendQuery(results_db,
                      sql("SELECT *
                          FROM game
                          WHERE CAST(leftstr(id,4) AS INT) > 2010
                          AND CAST(substr(id,6,7) AS INT) BETWEEN 4 AND 9"))
games <- dbFetch (gquery, n=-1)





 
#excluding ~150 variables


#creating win expectancy states 

gameresults$winstate <- with(gameresults, paste(inning_side.x, inning.x,
                               home_team_runs.x, away_team_runs.x, 
                               state_1b, state_2b, state_3b,
                               b, s, o))

#######Creating Win States - saved locally

WinDex <- data.frame("Game State" = unique(gameresults$winstate))

#total games observed in state

n_Obs <- function(i){
  return(nrow(gameresults[gameresults$winstate==i,]))
}

WinDex$observed <- sapply(WinDex$Game.State, n_Obs)


#wins observed in state

home_w <- function(i){
return(nrow(gameresults[gameresults$winstate==i & gameresults$home_team_runs.y > 
                          gameresults$away_team_runs.y,])
       /
         WinDex$observed[WinDex$Game.State==i,]) #home wins / total games
}

WinDex$Home_wPct <- sapply(WinDex$Game.State, home_w)
WinDex$Away_wPct <- 1-WinDex$Home_W



WinDex <- write.csv(Windex, "WinDex.csv", header=TRUE, sep=",")














##########################################################


outcomes <- data.frame()

for(i in 2011:2016){
  d <- getRetrosheet("game", i)
  outcomes <- rbind(outcomes, d)
}
outcomes <- outcomes[c("Date", "VisTm", "HmTm", "VisRuns","HmRuns")]
outcomes$Date <- with(outcomes, paste(substr(Date,0,4),substr(Date,5,6),
                                      substr(Date,7,8),sep="_"))
outcomes$HomeResult <- with(outcomes, ifelse(HmRuns>VisRuns, "W","L"))
outcomes$VisResult <- with(outcomes, ifelse(HomeResult=="W","L","W"))








gameresults <- subset(gameresults, substr(all$date,0,4)>2010&substr(all$date,0,4)<2016)
gameresults <- subset(gameresults, 
                      substr(all$date,5,6) == 10 & substr(all$date,7,8)<5 |
                        4 < substr(all$date,5,6) < 10 |
                        substr(all$date,5,6)==3 & substr(all$date,7,8)>30)




headerlist <- c("batter_name", "pitcher_name", 
                "count","b", "s", "o", "on_1b", "on_2b", "on_3b", 
                "inning_side.x", "inning.x", "home_team_runs.y", "away_team_runs.y",
                "type", "des", "event","event2", "event3", "event4",
                "pitch_type", "zone", "x", "y", "start_speed", "sz_top", "sz_bot", 
                "pfx_x", "pfx_z", "x0", "y0", "z0",
                "b_height", "stand", "p_throws", 
                "home_team_runs.x", "away_team_runs.x", "gameday_link"
)

gameresults = gameresults[headerlist]


dbSendQuery(my_db, sql("ALTER TABLE pitch
                       ADD Occupied1b
                       DEFAULT NULL"))

dbSendQuery(my_db, sql("ALTER TABLE pitch
                       ADD Occupied2b
                       DEFAULT NULL"))

dbSendQuery(my_db, sql("ALTER TABLE pitch
                       ADD Occupied3b
                       DEFAULT NULL"))


dbSendQuery(my_db, sql("UPDATE pitch
                        SET Occupied1b = CASE on_1b 
                       WHEN NULL THEN 'Empty'
                       ELSE 'Occupied'
                       END"))

dbSendQuery(my_db, sql("UPDATE pitch
                       SET Occupied2b = CASE on_2b 
                       WHEN NULL THEN 'Empty'
                       ELSE 'Occupied'
                       END"))

dbSendQuery(my_db, sql("UPDATE pitch
                       SET Occupied3b = CASE on_3b 
                       WHEN NULL THEN 'Empty'
                       ELSE 'Occupied'
                       END"))