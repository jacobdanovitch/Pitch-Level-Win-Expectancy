##############libraries#############

library(RSQLite)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(rJava)
library(xlsx)

#############data############################

db <- dbConnect(SQLite(), dbname = "PlsPitchF_X.sqlite3")
initExtension(db)
q <- dbSendQuery(db, sql("SELECT *
                           FROM WinEx"))
data <- dbFetch(q, n=-1)

#connecting to database

#######################model####################

m <- glm(w_Pct ~ b + s + out + state_1b + state_2b + state_3b + off_r_outs + def_r_outs + rd,
    family=binomial(link="logit"), data=data, weight=n)
data$pWE <- predict(m, type="response")

#generalized linear model to predict win expectancy based on state

################plot####################

plot(x=data$rd, y=data$w_rate)
spline <- smooth.spline(data$rd, data$w_rate, spar = 0.35)
lines(spline, col="red", lwd=2)

p1 <- ggplot(data = data, aes(x=data$rd, y=data$pWE))
p1+
  geom_point()+
  geom_smooth(color="dodgerblue3", size=1)+
  theme_fivethirtyeight()+
  ggtitle("Win Expectancy in Every State")+
  theme(axis.title = element_text())+
  ylab('helloworld')+
  labs(x = "Run Differential", y = "w%")+
  theme(panel.background = element_rect(fill = "grey95"),
        plot.background = element_rect(fill="grey95"))


###############################FILTERING####################3


winp <- function(out, off_r_outs, def_r_outs, b, s, rd, state_1b, state_2b, state_3b){
  
  print(predict(
    m,
    newdata = data.frame(
      out = out,
      off_r_outs = off_r_outs,
      def_r_outs = def_r_outs,
      b = b,
      s = s,
      rd = rd,
      state_1b = state_1b,
      state_2b = state_2b,
      state_3b = state_3b
    ),
    type = "response"
  ))
  
}


