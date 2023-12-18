##------------------------------------------------------------------------------
## Data and Package Imports
##------------------------------------------------------------------------------

## load packages
library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(shiny)
library(shinyWidgets)
library(shinyFeedback)
library(markdown)

## load data set
dataset = read_csv(file = "data/nba.csv")

##------------------------------------------------------------------------------
## Plot Code
##------------------------------------------------------------------------------

plot = function(min_dateGame, max_dateGame,
                min_game_fg3a, max_game_fg3a,
                min_game_fg3m, max_game_fg3m,
                min_career_fg3a, max_career_fg3a,
                min_career_fg3m, max_career_fg3m,
                min_season_pctFG3, max_season_pctFG3,
                min_season_fg3a, max_season_fg3a,
                min_season_fg3m, max_season_fg3m,
                player
) {

  ## ensure player argument is comma-separated and handles "All"
  if (identical(player, "All")) {
    players = dataset$namePlayer
  } else if (length(str_split_1(player, ", ") > 1)) {
    players = str_split_1(player, ", ")
  } else {
    players = player
  }

  ## wrangle data set so it adheres to plot arguments (this is the main df)
  df = dataset |>
    filter(namePlayer == players,
           dateGame <= max_dateGame & dateGame >= min_dateGame,
           fg3a <= max_game_fg3a & fg3a >= min_game_fg3a,
           fg3m <= max_game_fg3m & fg3m >= min_game_fg3m,
           career_fg3a <= max_career_fg3a & career_fg3a >= min_career_fg3a,
           career_fg3m <= max_career_fg3m & career_fg3m >= min_career_fg3m,
           season_fg3a <= max_season_fg3a & season_fg3a >= min_season_fg3a,
           season_fg3m <= max_season_fg3m & season_fg3m >= min_season_fg3m,
           season_pctFG3 <= max_season_pctFG3 & season_pctFG3 >= min_season_pctFG3)

  ## create df so each individual player gets their own color on the graph
  unique_player_colors = df |>
    distinct(idPlayer, .keep_all = TRUE)

  ## customize subtitle text so it reflects number of players displayed
  if (length(players) <= 4) {
    subtitle_text = str_flatten(players, ", ")
  } else if (nrow(unique_player_colors) <= 4) {
    subtitle_text = str_flatten(unique_player_colors$namePlayer, ", ")
  } else {
    subtitle_text = paste(nrow(unique_player_colors), "NBA Players")
  }

  ggplot(data = df,
         mapping = aes(x = dateGame,
                       y = career_fg3m,
                       color = player_and_seasons)) +
    ## switch from path plot to point-line plot if players displayed <= 100
    {if (nrow(df) <= 100) {
      geom_point()
    } else {
      geom_path()
    }} +
    {if (nrow(df) <= 100) {
      geom_line()
    }} +
    labs(
      title = "Cumulative 3-Pointers Made by Season",
      subtitle = paste("For", subtitle_text),
      x = "Date",
      y = "Cumulative 3-Pointers Made",
      color = ifelse(length(players) > 1,
                     "Player Names and Career Duration",
                     "Player Name and Career Duration")
    ) +
    ## if graph displays 10+ players, omit color legend
    guides(color = ifelse(nrow(unique_player_colors) > 10,
                          "none", guide_colorbar())) +
    scale_x_date(breaks = seq.Date(from = min_dateGame,
                                   to = max_dateGame,
                                   by = "2 years"),
                 date_labels = "%Y",
                 limits = c(min_dateGame, max_dateGame)) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5),
          plot.subtitle = element_text(face = "italic", hjust = 0.5),
          axis.text.x = element_text(angle = 45))

}
