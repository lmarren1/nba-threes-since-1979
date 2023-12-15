ui = navbarPage(

  title = "NBA",

  tabPanel(

    title = "Input / Visualization",

    titlePanel(title = "NBA 3-Point Data Since 1979"),

    sidebarLayout(

      sidebarPanel(

        textAreaInput(inputId = "player_input",
                      label = "Player(s) Selected",
                      value = "All",
                      placeholder = "Enter Player Names\n- 'All' Returns All NBA Players",
                  width = "375px", height = "50px"),

        useShinyFeedback(),

        textOutput(outputId = "player_validation"),

        dateRangeInput(inputId = "dateGame_input", label = "Date Range",
                       start = min(dataset$dateGame),
                       end = max(dataset$dateGame),
                       min = min(dataset$dateGame),
                       max = max(dataset$dateGame),
                       startview = "year"),
        textOutput(outputId = "dateGame_validation"),

        sliderInput(inputId = "game_fg3a_input", label = "3-Point Attempts (by Game)",
                    value = c(0, max(dataset$fg3a)),
                    min = 0, max = max(dataset$fg3a)),

        sliderInput(inputId = "game_fg3m_input", label = "3-Point Makes (by Game)",
                    value = c(0, max(dataset$fg3m)),
                    min = 0, max = max(dataset$fg3m)),

        numericRangeInput(inputId = "season_fg3a_input",
                          label = "3-Point Attempts Range (by Season)",
                          value = c(0, max(dataset$season_fg3a)),
                          min = 0, max = max(dataset$season_fg3a)),

        numericRangeInput(inputId = "season_fg3m_input",
                          label = "3-Point Makes Range (by Season)",
                          value = c(0, max(dataset$season_fg3m)),
                          min = 0, max = max(dataset$season_fg3m)),

        numericRangeInput(inputId = "career_fg3a_input",
                          label = "3-Point Attempts Range (Over Career)",
                          value = c(0, max(dataset$career_fg3a)),
                          min = 0, max = max(dataset$career_fg3a)),

        numericRangeInput(inputId = "career_fg3m_input",
                          label = "3-Point Makes Range (Over Career)",
                          value = c(0, max(dataset$career_fg3m)),
                          min = 0, max = max(dataset$career_fg3m)),

        sliderInput(inputId = "season_pctFG3_input", label = "3-Point % Range (by Season)",
                    value = c(0, max(dataset$season_pctFG3)),
                    min = 0, max = max(dataset$season_pctFG3))
      ),

      mainPanel(

          plotOutput(outputId = "plot", width = "1000px", height = "600px",
                     hover = hoverOpts(id = "plot_hover", delay = 50)),

          dataTableOutput(outputId = "hover_data")
      )
    )
  ),
  tabPanel(
    title = "Table",
    column(align = "center",
           width = 12,
           titlePanel(title = "Game, Season, and Career 3-Point Data by Player"),
           dataTableOutput(outputId = "table")
           )
  ),
  tabPanel(
    title = "About",
    includeMarkdown("about.Rmd")
  )
)

server = function(input, output, session) {

  slider_updater = reactive({
    if (input$player_input == "All") {
      players = dataset$namePlayer
    } else if (length(str_split_1(input$player_input, ", ") > 1)) {
      players = str_split_1(input$player_input, ", ")
    } else {
      players = input$player_input
    }
    updated_dataset = dataset |>
      filter(namePlayer == players)
  })

  filtered_slider_updater = reactive({
    slider_updater() |>
      filter(dateGame <= input$dateGame_input[[2]] & dateGame >= input$dateGame_input[[1]],
             fg3a <= input$game_fg3a_input[[2]] & fg3a >= input$game_fg3a_input[[1]],
             fg3m <= input$game_fg3m_input[[2]] & fg3m >= input$game_fg3m_input[[1]],
             season_fg3a <= input$season_fg3a_input[[2]] & season_fg3a >= input$season_fg3a_input[[1]],
             season_fg3m <= input$season_fg3m_input[[2]] & season_fg3m >= input$season_fg3m_input[[1]],
             career_fg3a <= input$career_fg3a_input[[2]] & career_fg3a >= input$career_fg3a_input[[1]],
             career_fg3m <= input$career_fg3m_input[[2]] & career_fg3m >= input$career_fg3m_input[[1]],
             season_pctFG3 <= input$season_pctFG3_input[[2]] & season_pctFG3 >= input$season_pctFG3_input[[1]],
             .by = c(idPlayer, yearSeason)) |>
      distinct(idPlayer, .by = dateGame, .keep_all = TRUE) |>
      select(namePlayer, dateGame, yearSeason, fg3a, fg3m, pctFG3, season_fg3a,
             season_fg3m, season_pctFG3, career_fg3a, career_fg3m)
  })

  observeEvent(
    eventExpr = input$player_input,
    handlerExpr = {
      updateDateRangeInput(inputId = "dateGame_input", label = "Date Range",
                           start = min(slider_updater()$dateGame),
                           end = max(slider_updater()$dateGame))

      updateSliderInput(inputId = "game_fg3a_input",
                        label = "3-Point Attempts (by Game)",
                        value = c(min(slider_updater()$fg3a), max(slider_updater()$fg3a)))

      updateSliderInput(inputId = "game_fg3m_input",
                        label = "3-Point Makes (by Game)",
                        value = c(min(slider_updater()$fg3m), max(slider_updater()$fg3m)))

      updateNumericRangeInput(inputId = "season_fg3a_input",
                              label = "3-Point Attempts Range (by Season)",
                              value = c(min(slider_updater()$season_fg3a), max(slider_updater()$season_fg3a)))

      updateNumericRangeInput(inputId = "season_fg3m_input",
                              label = "3-Point Makes Range (by Season)",
                              value = c(min(slider_updater()$season_fg3m), max(slider_updater()$season_fg3m)))

      updateNumericRangeInput(inputId = "career_fg3a_input",
                              label = "3-Point Attempts Range (Over Career)",
                              value = c(min(slider_updater()$career_fg3a), max(slider_updater()$career_fg3a)))

      updateNumericRangeInput(inputId = "career_fg3m_input",
                              label = "3-Point Makes Range (Over Career)",
                              value = c(min(slider_updater()$career_fg3m), max(slider_updater()$career_fg3m)))

      updateSliderInput(inputId = "season_pctFG3_input",
                        label = "3-Point % Range (by Season)",
                        value = c(min(slider_updater()$season_pctFG3) - 1, max(slider_updater()$season_pctFG3) + 1))
    }
  )

  output$player_validation = renderText({
    player_input = str_split_1(input$player_input, ", ")
    correct_player_input = all(player_input %in% dataset$namePlayer) | identical(player_input, "All")
    if (!correct_player_input) {
      validate("Player Names Must Be Capitalized and Comma-Separated")
    }
  })

  output$dateGame_validation = renderText({
    correct_date_input = input$dateGame_input[[1]] <= input$dateGame_input[[2]]
    if (!correct_date_input) {
      validate("Dates Must Not Overlap")
    }
  })

  output$plot <- renderPlot({
    notification = showNotification("Loading Plot...",
                                    duration = NULL, closeButton = NULL,
                                    type = "message")
    on.exit(removeNotification(notification), add = TRUE)
    player_input = str_split_1(input$player_input, ", ")
    correct_player_input = all(player_input %in% dataset$namePlayer) | identical(player_input, "All")
    req(correct_player_input)
    plot(min_dateGame = input$dateGame_input[[1]], max_dateGame = input$dateGame_input[[2]],
         min_game_fg3a = input$game_fg3a_input[[1]], max_game_fg3a = input$game_fg3a_input[[2]],
         min_game_fg3m = input$game_fg3m_input[[1]], max_game_fg3m = input$game_fg3m_input[[2]],
         min_career_fg3a = input$career_fg3a_input[[1]], max_career_fg3a = input$career_fg3a_input[[2]],
         min_career_fg3m = input$career_fg3m_input[[1]], max_career_fg3m = input$career_fg3m_input[[2]],
         min_season_fg3a = input$season_fg3a_input[[1]], max_season_fg3a = input$season_fg3a_input[[2]],
         min_season_fg3m = input$season_fg3m_input[[1]], max_season_fg3m = input$season_fg3m_input[[2]],
         min_season_pctFG3 = input$season_pctFG3_input[[1]], max_season_pctFG3 = input$season_pctFG3_input[[2]],
         player = input$player_input)},
  res = 96)

  output$hover_data <- renderDataTable({
    notification = showNotification("Loading Mouse Hover Data...",
                                    duration = NULL, closeButton = NULL,
                                    type = "message")
    on.exit(removeNotification(notification), add = TRUE)
    req(input$plot_hover)
    nearPoints(filtered_slider_updater(), input$plot_hover, maxpoints = 2)
  })

  output$table = renderDataTable({
    notification = showNotification("Loading Data Table...",
                                    duration = NULL, closeButton = NULL,
                                    type = "message")
    on.exit(removeNotification(notification), add = TRUE)
    filtered_slider_updater()
  })
}

shinyApp(ui, server)

