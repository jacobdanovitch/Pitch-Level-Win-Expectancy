#########################   LIBRARIES   #################################

library(RSQLite)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(randomForest)



#######################   GROUPED STATE RF MODEL   #######################


###Collect and clean data###

db <- dbConnect(SQLite(), dbname = "PlsPitchF_X.sqlite3")
initExtension(db)


q <- dbSendQuery(db, sql("SELECT *
                         FROM WinEx"))
data <- dbFetch(q, n=-1)


data$side <- as.factor(data$side) 

###Allocate training and validation data###
rf_sample <- sample(2, 
                    nrow(data),
                    replace = T,
                    prob = c(0.6,0.4))
training <- data[rf_sample==1,]
validation <- data[rf_sample==2,]

###Create RF model###
#training <- subset(training, select = -n)
rf_model <- randomForest(formula = w_Pct ~ .,
                         data=training,
                         ntree=35,
                         weights=n
)

plot(rf_model)

###Out of sample testing
validation$rf_W <- predict(rf_model, validation)
summary(lm(w_Pct ~ rf_W, data=validation)) ###90.92% R-squared

data$rf_W <- predict(rf_model, data)


##############################   SUMMING PLAYER W% CHANGES   ######################

###Select and clean data
current <- dbSendQuery(db, sql("SELECT *
                           FROM appliedWE
                         WHERE substr(time,1,4) = '2016'"))
thisyear <- dbFetch(current, n=-1)
thisyear$side <- as.factor(thisyear$side)

###Merge pbp with associated game state/win info
thisyear <- merge(thisyear, data, all.x=TRUE, by=c("out", "off_r_outs", "def_r_outs", 
                                       "b","s", "rd",
                                       "state_1b", "state_2b", "state_3b"))
thisyear <- thisyear[order(thisyear$gameday_link, thisyear$num, thisyear$time),] ###re-order

###Sampling so that I don't have to wait 2 hours to see if my code is good
#gameIDs <- unique(thisyear$gameday_link)
#smalldata <- subset(thisyear, gameday_link %in% gameIDs[1:3])

thisyear$batter_team <- 0

thisyear[sapply(thisyear$side.x,paste0,collapse="")=="bottom","batter_team"] <- "home"
thisyear[sapply(thisyear$side.x,paste0,collapse="")=="top","batter_team"] <- "away"

###Tracking changes in WE

thisyear$batterWE <- ifelse(thisyear$batter_team=="home",thisyear$rf_W,1-thisyear$rf_W)
thisyear$pitcherWE <- 1-thisyear$batterWE

thisyear$batter_next_WE <- 0
thisyear$pitcher_next_WE <- 0

###loop through all pitches and find next WE
for(i in 1:nrow(thisyear)){ 
  
  ### if next row is same game
  if(identical(thisyear$gameday_link[i],thisyear$gameday_link[i+1])==TRUE){ 
    
    ###if batter is on home team
    if(thisyear$batter_team[i]=="home"){
      
      thisyear$batter_next_WE[i] <- thisyear$rf_W[i+1] ###take next homeW%
      thisyear$pitcher_next_WE[i] <- 1-thisyear$batter_next_WE[i] ###away team pitcher gets inverse
      
    }
    ###if batter is on away team
    else if(thisyear$batter_team[i]=="away"){ 
      
      
      thisyear$pitcher_next_WE[i] <- thisyear$rf_W[i+1] ###pitcher takes next homeW%
      thisyear$batter_next_WE[i] <- 1-thisyear$pitcher_next_WE[i] ###away team batter gets inverse
      
    }
    
  }
  ### if next row is not in same game
  else if(identical(thisyear$gameday_link[i],thisyear$gameday_link[i+1])==FALSE){ 
    
    ###and bottom of last inning
    if(thisyear$batter_team[i] == "home"){ 
      
      ###and home team winning
      if(thisyear$rd[i] > 0){ 
        
        thisyear$batter_next_WE[i] <- 1
        thisyear$pitcher_next_WE[i] <- 0
        
      }
      ###and away team winning
      if(thisyear$rd[i] < 0){ 
        
        thisyear$pitcher_next_WE[i] <- 1
        thisyear$batter_next_WE[i] <- 0
        
      } 
    }
    ###and top of last inning
    else if(thisyear$batter_team[i] == "away"){
      ###and home team winning
      if(thisyear$rd[i] > 0){
        
        thisyear$pitcher_next_WE[i] <- 1
        thisyear$batter_next_WE[i] <- 0
        
      }
      ###and away team winning
      else if(thisyear$rd[i] < 0){
        
        thisyear$pitcher_next_WE[i] <- 0
        thisyear$batter_next_WE[i] <- 1
        
      }
    }
  }
}

###Difference in WE between pitches
thisyear$batterDiff <- with(thisyear, batter_next_WE - batterWE) 
thisyear$pitcherDiff <- with(thisyear, pitcher_next_WE - pitcherWE)


###Compiling

batters <- unique(thisyear$batter[!(is.na(thisyear$batter))])
pitchers <- unique(thisyear$pitcher[!(is.na(thisyear$pitcher))])

players <- unique(c(batters,pitchers))

computeBatter <- function(player_name){
  
  sum(filter(thisyear, batter == player_name)$batterDiff)
  
}

computePitcher <- function(player_name){
  
  sum(subset(thisyear, pitcher == player_name)$pitcherDiff)
  
}


#appy functions to sum every player's data
oAWE <- sapply(players, computeBatter) 
dAWE <- sapply(players, computePitcher)

final <- data.frame(Player=players, oAWE, dAWE) #creates data frame of HR's/players
final$AWE <- with(final, oAWE + dAWE)
final <- final[order(final$AWE, decreasing = TRUE), ] #sort

write.csv(final, "AWE.csv")

write.csv(thisyear, "FullData.csv")

##################################################################################################


###DOOOOOOOOOOOOOOOOOOONE


#######################   PBP-based RF Model   ##################################

###Select all data from 2013 onwards

recent <- dbSendQuery(db, sql("SELECT *
                              FROM Random_Forest
                              WHERE CAST(substr(gameday_link,5,4) AS INT) > 2012"))
data <- dbFetch(recent, n=-1)

###Cleaning data
data$side <- as.factor(data$side) 
data$home_Result <- as.character(data$home_Result)
data$home_Result <- as.factor(data$home_Result)

###Allocating training and validation data
rf_sample <- sample(2, 
                    nrow(data),
                    replace = T,
                    prob = c(0.6,0.4))
training <- data[rf_sample==1,]
training <- subset(training, select = -gameday_link)
validation <- data[rf_sample==2,]


rf_model <- randomForest(formula = home_Result ~ .,
                         data=training,
                         ntree=20)

plot(rf_model) ###Number of trees at which point error approaches constant
###Error approaches constant around 20 trees

varImpPlot(rf_model,
           sort = T,
           main="Variable Importance",
           n.var=5) 

### T5 variables: RD (wide margin), off/def_r_outs, inn, out

training$rf_W <- predict(rf_model,training)


###Out of sample testing

validation$rf_W <- predict(rf_model,validation)

validation$success <- ifelse((validation$rf_W==1 & validation$home_Result == 1) 
                             | (validation$rf_W==0 & validation$home_Result == 0),
                             1, 0) ###If predicted and observed align, success 

nrow(subset(validation, success==1))/nrow(validation)
###75.74% out of sample accuracy

###Testing classification accuracy of grouped states model on PBP data###
test <- dbFetch(recent, n=-1)
test$side <- as.factor(test$side)
test$pred_prob <- predict(rf_model, test)

test$absolute_pred <- ifelse(test$pred_prob > .4999,"Y", "N") ###If p(win)>.5, pred=win, else loss
nrow(subset(test, absolute_pred=="Y" & home_Result == 1))/nrow(subset(test, absolute_pred=="Y")) ###Accuracy of win predicted and observed
nrow(subset(test, absolute_pred=="N" & home_Result == 0))/nrow(subset(test, absolute_pred=="N")) ###Accuracy of loss predicted and observed

# Accuracy of classification roughly 75% on avg with limited model. Not worth the effort
# when comparing to faster, more intuitive, more simple model. Strongly doubt benefits 
# would be beyond ~5% improvement
