# Win Expectancy For Any Pitch in a Baseball Game

Breaking down the popular concept of win expectancy into a more granular, pitch-by-pitch input. 

## How it works

I scraped MLB Gameday's pitch f/x database going back to 2008, and used data back to 2013 in my analysis. I grouped every observed, unique state seen in a baseball game (for example: 1 out, 2-1 count, home team down by 2, bases empty, 3rd inning), and trained a Random Forest model to predict the win expectancy for any given state. 

I chose to use a model rather than tweaking observed data for outlier situations - say, very large defecits, or extra inning situations. The lower number of observations tends to sway the win expectancy towards 0 or 1, and can be incredibly impactful and misleading in the final analysis. My model explained 90.61% of the variation in observed win expectancy between these states.

From there, I calculated the win expectancy for every pitch of the 2016 season. I then calculated the win expectancy for the *next* pitch, and found the delta. I summed the deltas to give me a pitch by pitch level of Win Probability Added (WPA).

## Applications

Win expectancy can be utilized in a variety of ways. It can tell teams which players are doing the most to contribute in an easy to understand and intuitive way, and it can explain the pros and cons of various strategic decisions.

The first application of my project is to be able to analyze the best players in baseball by how much they affect their team's win expectancy.

The second application (in progress) is to be able to analyze strategy more in depth than previous instances of WPA. Previously, the metric was best suited for between at bats (bunting, sending a runner to steal, etc). Now, however, we should be able to quantify decisions such as the value of throwing a particular pitch - even down to the location.

## Current (Known) Problems

* When adjusting the run differential to be reflective of the current at bat on scoring plays, SQLite seemingly refuses to do anything despite the code working on sample data sets.

### Built With

* **R** - Used to create model and complete data analysis
* **SQLite** - Used to manage Pitch F/X data

### Authors

* **Jacob Danovitch** - Creator of project - [Danolytics](http://danolytics.com)

#### Acknowledgments

* Mitchel Lichtman, co-author of "The Book: Playing the Percentages in Baseball" for his time and brain power assisting on this
* The authors of the Pitch R/X library for making my life 1000x easier 
* All my friends I annoyed endlessly about my various struggles and ineptitudes with this project
* Not SQLite (why can't you do literally anything you can do in any other SQL variant, Christ)

Watch for a write-up and check out my other projects at my blog on [Danolytics](https://medium.com/danolytics)
