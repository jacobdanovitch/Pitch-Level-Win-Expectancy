#libraries

library(dplyr)
library(pitchRx)
library(RSQLite)

db <- src_sqlite("PlsPitchF_X.sqlite3")#, create = TRUE)
db <- dbConnect(SQLite(), "PlsPitchF_X.sqlite3")


#scrape without murdering RAM

effscr <- function(s, e){ #s : start date, e : end date
  
  yrs <- c(s:e)
  
  for (i in yrs){
    
    
    scrape(start = paste(i,"-04-01",sep=""), end = paste(i,"-10-05", sep=""), 
           suffix=c("inning/inning.all","miniscoreboard.xml"), con = db)
    
    Sys.sleep(60*3)
  }
}

#effscr(2010,2016)


install.packages("RSQLite")
install.packages("pitchRx")

db <- dbConnect(SQLite(), "GraydonisDumn.sqlite3", create=T)

scrape(start = "2010-04-01", end = "2010-04-05",
       suffix=c("inning/inning.all","miniscoreboard.xml"), con = db)










#Updates until yesterday
update_db(db, end = Sys.Date() - 1)

