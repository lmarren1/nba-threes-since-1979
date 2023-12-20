# NBA Threes Since 1979

## Purpose

This Shiny app is designed to give NBA 'stat fanatics' a medium to interact with player 
3-point data in ways typically unavailable on major NBA statistics platforms. Users can uncover hidden insights on over 3000 NBA players since the birth of the 3-point line.

## Preview

[Play around with it yourself here!](https://luke-marren.shinyapps.io/nba-app/)

<p align="center">
<img src="app-preview.gif" width="800">
</p>

## Setup

### Prerequisites
Make sure you have both [R and RStudio](https://posit.co/download/rstudio-desktop/) downloaded before running any code.

From there, depending on your local machine specs, you may need to run the command:
```R
Sys.setenv("VROOM_CONNECTION_SIZE" = 500000)
```
to ensure the [data set](data/nba.csv) used in this app can load and display in your environment. If that is the case, the [setup.R](setup.R) file already has that code snippet set to run.

The following packages must be installed on your computer for the [app.R](app.R) and [R/functions.R](R/functions.R) files to run:
- `tidyverse`
- `shiny`
- `shinyWidgets`
- `shinyFeedback`
- `markdown`

To install these packages, copy and run this in the console:
```R
install.packages(c("tidyverse", "shiny", "shinyWidgets", "shinyFeedback", "markdown"))
```

All analogous library calls are included in the [R/functions.R](R/functions.R) file.

### Usage

To use the Shiny app, first run the `setup.R` script. This may take a while as there are over one million observations to load.

Then move to `app.R` and the click the “Run App” button on the top right of the script.

## References 

Data Set Source:

- [abresler / nbastatR](https://github.com/abresler/nbastatR)

App Inspiration:

- [NYT: Stephen Curry's 3-Point Record in Context: Off the Charts](https://www.nytimes.com/interactive/2016/04/16/upshot/stephen-curry-golden-state-warriors-3-pointers.html)

View(gs_point_by_point)
