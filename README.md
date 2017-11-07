# Win Expectancy For Any Pitch in a Baseball Game

Breaking down the popular concept of win expectancy into a more granular, pitch-by-pitch estimate.

Note (October 11, 2017): I completed this project in my grade 12 year of high school. I tried to complete it quickly for university applications and the like, which placed a lot of constraints on what I wanted to do with the project. However, the purpose of this project was not to be another box on my resume. As, erm, let's go with "polarizing," this project may be (really good sometimes, really bad others), I really had a ton of fun with it and learned a lot. Looking back on it as a first year university student, I regret my resentment towards it for being "just a sports stats project." I think I should really try to do more projects like this one.

## How it works

Using the pitchRx package, I scraped MLB Gameday's pitch f/x database going back to 2008, and used data back to 2013 in my analysis. I grouped every observed, unique state (see example below) seen in a baseball game. I then trained a Random Forest model to estimate the win expectancy for any given state.  <br/> <br/>
**Example of pitch state**
```
1 out
2-1 count
Home team down by 2
Bases empty
3rd inning
```

I chose to use a model rather than tweaking observed data for outlier situations - say, very large defecits, or extra inning situations. The lower number of observations tends to sway the win expectancy towards 0 or 1, and can be incredibly impactful and misleading in the final analysis. My model explained 90.61% of the variation in observed win expectancy throughout all states.

From there, I calculated the win expectancy for every pitch of the 2016 season. I then calculated the win expectancy for the *next* pitch, and found the delta. I summed the deltas to give me a pitch by pitch level measure of Win Probability Added (WPA).

## What I Learned

Being my first large-scale project, I learned a lot about different areas of computer science and data science. One of the most important things I learned was the impact of efficiency. Ironically, I could have saved a lot of time, and been a lot more productive, had I simply slowed down. I should have split my data into a very, very small "initialization" partition on which to ensure my code worked, before creating my testing and training partitions.

Perhaps the area I learned the most about was data processing. I'm lucky that I was able to disillusion myself early on of the popular notion that data science is all about testing new algorithms and getting awesome results right away. This project taught me a ton about the importance of processing your data, and that little errors will always be hiding somewhere. I learned how to use SQL (or whatever god-forsaken approximation of it SQLite claims to be), which was very useful in managing big sets of data. I also learned why SQL is so useful for larger datasets in the first place, the difference between writing transactions to storage (SQL) and holding data in memory (R, Python). I've heard that experientially is the best way to learn, so the experience of repeatedly crashing my computer by trying to hold a 13 gigabyte dataset in memory with R probably taught me a lot.

I also had the opportunity to learn about Random Forest models, which really excited me and interested me in the field of machine learning. The concept is incredibly intuitive and the package was (mostly) easy to use.

Finally, the last thing I learned was **don't commit database transaction on your 13 GB dataset without understanding and testing it first because that thing took weeks to download and you ruined all of it honestly what's wrong with you?**

## Applications

Win expectancy can be utilized in a variety of ways. It can tell teams which players are doing the most to contribute in an easy to understand and intuitive way, and it can explain the pros and cons of various strategic decisions.

The first application of my project is to be able to analyze the best players in baseball by how much they affect their team's win expectancy on a pitch-by-pitch basis.

The second application is to be able to analyze strategy more in depth than previous instances of WPA. Previously, the metric was best suited for between at bats (bunting, sending a runner to steal, etc). Now, however, we should be able to quantify decisions such as the value of throwing a particular pitch - even down to the location. Mitchel Lichtman, co-author of [The Book: Playing the Percentages in Baseball](https://www.amazon.ca/Book-Playing-Percentages-Baseball-ebook/dp/B00GW6A89Y/ref=sr_1_1?s=books&ie=UTF8&qid=1510078685&sr=1-1&keywords=The+book+baseball) is vocal about potential game-theory applications of this information, and was extremely helpful in assisting me with this project.

## Future Plans

* Integrate model with personal website to allow users to examine how different features affect win probability between pitches
* Set up server to host data

## Current (Known) Problems

* Must adjust the run differential to be reflective of the current at bat on scoring plays
* Must optimize SQLite codebase and triggers to minimize run time, or move platforms

### Built With

* **R** - Used to create model and complete data analysis
* **SQLite** - Used to manage Pitch F/X data

#### Acknowledgments

* Mitchel Lichtman, co-author of "The Book: Playing the Percentages in Baseball" for his time and brain power assisting on this
* The authors of the Pitch R/X library for making my life 1000x easier 
* All my friends I annoyed endlessly about my ~~stupidity~~ various struggles with this project
* Not SQLite (note to self: please switch db format to literally anything else, and never use this again)
