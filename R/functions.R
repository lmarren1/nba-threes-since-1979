library(dplyr)
library(tidyverse)
library(ggthemes)
library(ggplot2)
library(shiny)
library(shinyWidgets)
library(shinyFeedback)

dataset = read_csv(file = "data/nba.csv")

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

  if (identical(player, "All")) {
    players = dataset$namePlayer
  } else if (length(str_split_1(player, ", ") > 1)) {
    players = str_split_1(player, ", ")
  } else {
    players = player
  }

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

  df_for_color_guide = df |>
    distinct(idPlayer, .keep_all = TRUE)

  if (length(players) <= 4) {
    subtitle_text = str_flatten(players, ", ")
  } else if (nrow(df_for_color_guide) <= 4) {
    subtitle_text = str_flatten(df_for_color_guide$namePlayer, ", ")
  } else {
    subtitle_text = paste(nrow(df_for_color_guide), "NBA Players")
  }

  ggplot(data = df,
         mapping = aes(x = dateGame,
                       y = career_fg3m,
                       color = player_and_seasons)) +
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
      color = ifelse(length(players) > 1, "Player Names and Career Duration", "Player Name and Career Duration")
    ) +
    guides(color = ifelse(nrow(df_for_color_guide) > 10, "none", guide_colorbar())) +
    scale_x_date(breaks = seq.Date(from = min_dateGame,
                                   to = max_dateGame,
                                   by = "2 years"),
                 date_labels = "%Y",
                 limits = c(min_dateGame, max_dateGame)) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5),
          plot.subtitle = element_text(face = "italic", hjust = 0.5),
          axis.text.x = element_text(angle = 45))

}
