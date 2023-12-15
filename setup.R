library(tidyverse)
library(devtools)

devtools::install_github("abresler/nbastatR")
library(nbastatR)

Sys.setenv("VROOM_CONNECTION_SIZE" = 500000)

game_logs_since_1980 = game_logs(seasons = 1980:2024)

focused_games_since_1980 = game_logs_since_1980 |>
  select(dateGame, yearSeason, namePlayer,
         idPlayer, fg3a, fg3m, pctFG3)

focused_games_since_1980 = focused_games_since_1980 |>
  replace(is.na(focused_games_since_1980), 0) |>
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
  filter(career_fg3a >= 1)

View(focused_games_since_1980)

write_csv(x = focused_games_since_1980, file = "data/nba.csv")

