# Preliminary Data Import ------------------------------------------------------

library(tidyverse)
library(devtools)

devtools::install_github("abresler/nbastatR")
library(nbastatR)

# Ensure local machine can load and display the massive data set
Sys.setenv("VROOM_CONNECTION_SIZE" = 500000)

game_logs_since_1980 <- game_logs(seasons = 1980:2024)

# Preliminary Data Wrangling ---------------------------------------------------

# All 13 variables used in this project are based off the 7 selected here
focused_games_since_1980 <- game_logs_since_1980 |>
  select(dateGame, yearSeason, namePlayer,
         idPlayer, fg3a, fg3m, pctFG3)

focused_games_since_1980 <- focused_games_since_1980 |>
  # Original data set contained some missing values for shot attempts
  replace(is.na(focused_games_since_1980), 0) |>
  # Add new analysis variables (e.g., player_and_seasons is for player ID)
  mutate(pctFG3 = round(pctFG3, digits = 4) * 100) |>
  mutate(career_fg3a = cumsum(fg3a),
         career_fg3m = cumsum(fg3m),
         player_and_seasons = paste(
           str1 = paste(str1 = namePlayer, str2 = min(yearSeason), sep = " : "),
           str2 = max(yearSeason),
           sep = "-"),
         .by = idPlayer) |>
  mutate(season_fg3a = sum(fg3a),
         season_fg3m = sum(fg3m),
         season_pctFG3 = {
           if (max(season_fg3a) == 0) {
             0
           } else if (max(season_fg3m) > max(season_fg3a)) {
             0
           } else {
             round(season_fg3m / season_fg3a, digits = 4) * 100
           }
         },
         .by = c(idPlayer, yearSeason)) |>
  select(namePlayer, idPlayer, player_and_seasons, dateGame, yearSeason, fg3a,
         season_fg3a, fg3m, season_fg3m, pctFG3,
         season_pctFG3, career_fg3a, career_fg3m) |>
  relocate(namePlayer, idPlayer, player_and_seasons, dateGame, yearSeason, fg3a,
           season_fg3a, fg3m, season_fg3m, pctFG3,
           season_pctFG3, career_fg3a, career_fg3m) |>
  # Only include players with >= 1 3pt attempt in their career
  filter(career_fg3a >= 1)

# (Optional) Store data locally ------------------------------------------------

write_csv(x = focused_games_since_1980, file = "data/nba.csv")
