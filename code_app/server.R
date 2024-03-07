server <- function(input, output) {

  # define some basic credentials (on data.frame)
  credentials <- data.frame(
    user = c("emmy-dash-beta"), # mandatory
    password = c('$2y$10$.mjvDK6xnfSnBvxeCa9lPeBdu3i8XcrJworwh8Kw5ISXyQMhcrE6i'), # mandatory
    # start = c("2024-01-01"), # optinal (all others)
    # expire = c(NA, "2025-12-31"),
    admin = c(TRUE),
    comment = "Simple and secure authentification mechanism for single ‘Shiny’ applications.",
    stringsAsFactors = TRUE
  )

  # call the server part
  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

  output$auth_output <- renderPrint({
    reactiveValuesToList(res_auth)
  })

  # Only Convert Boolean to Regex
  bool_to_regex <- function(boolQ, ignore_case = TRUE, wildcard = FALSE) {

    # Convert Boolean to Regex

    inclOR <- gsub(" OR ", "|", boolQ, ignore.case = TRUE)
    inclAND <- gsub(" AND ", "\\(\\?\\:\\.\\+\\)" , inclOR, ignore.case = TRUE)

    # Case Sensitive Flag
    if (ignore_case) {

      out <- tolower(inclAND)

    } else {

      out <- inclAND

    }

    # Wildcard Flag
    if (wildcard) {

      outWild <- gsub("\\*", "\\.\\*", out)
      return(outWild)

    }

    return(out)

  }

  format_query = function(oquery, ignore_case = TRUE, wildcard = TRUE) {

    isRegex = stringr::str_detect(oquery, "\\|")

    if (isRegex) {

      if (ignore_case) {

        out = tolower(oquery)

      } else {

        out = oquery

      }

    } else {

      out <- bool_to_regex(oquery, ignore_case = ignore_case, wildcard = wildcard)

    }

    return(out)

  }

  # create loaders
  tbl <- addLoader$new("tbl", type = "facebook")

  data <- reactiveVal(NULL)
  timing <- reactiveVal(NULL)


  observeEvent(input$create_button, {

    shinyalert("Query Execution in Process ... ",
               paste("\nPlease consider that this requirement could take around 20-30 minutes,
        depending on the size of the data.\n
        \nDo not press the 'Ok' button until the data is generated.\n"),
               paste("Timing Information:\n", Sys.time()), type = "success")


    if(input$filter_db == "core"){

      # Measure the time it takes to execute the query
      timing_start <- Sys.time()

      regexQCode <- input$filter_code_core

      regexQ <- ""  # Initialize regexQ outside the if condition

      if (!is.null(input$filter_regex) && length(input$filter_regex) > 0 && input$filter_regex == TRUE) {
        regexQ <- format_query(oquery = input$filter_regex, ignore_case = input$checkbox1, wildcard = input$checkGroup2)
        return(regexQ)
      }

      query <- paste0("CREATE TABLE source_data AS (SELECT title, snippet, publication_date_mdy, language_code, source_name, source_code, publisher_name, title, body, word_count FROM '/database/coreData/*snappy.parquet' WHERE (publication_date_mdy >='", input$daterange1[1], "' AND publication_date_mdy <= '", input$daterange1[2],  "' AND source_name = '", regexQCode, "'));")

      con <- dbConnect(duckdb::duckdb(), ":memory:", port = "3838")

      dbExecute(con, query)

      newDF <- tbl(con, "source_data") %>%
        filter(grepl(regexQ, title, ignore.case = TRUE) | grepl(regexQ, body, ignore.case = TRUE)) %>%
        collect()

      # Record the time taken
      timing_end <- Sys.time()
      timing_duration <- timing_end - timing_start
      timing(timing_duration)

      data(newDF)

      dbDisconnect(con, shutdown = TRUE)

    }

    if(input$filter_db == "additional"){

      # Measure the time it takes to execute the query
      timing_start <- Sys.time()

      regexQCode <- input$filter_code_additional
      # regexQ <- format_query(oquery = input$filter_regex)
      regexQ <- ""  # Initialize regexQ outside the if condition

      if (!is.null(input$filter_regex) && length(input$filter_regex) > 0 && input$filter_regex == TRUE) {
        regexQ <- format_query(oquery = input$filter_regex, ignore_case = input$checkbox1, wildcard = input$checkGroup2)
        return(regexQ)
      }

      query <- paste0("CREATE TABLE source_data AS (SELECT title, snippet, publication_date_mdy, language_code, source_name, source_code, publisher_name, title, body, word_count FROM '/database/additionData/*snappy.parquet' WHERE (publication_date_mdy >='", input$daterange1[1], "' AND publication_date_mdy <= '", input$daterange1[2],  "' AND source_name = '", regexQCode, "'));")

      con <- dbConnect(duckdb::duckdb(), ":memory:", port = "3838")

      dbExecute(con, query)

      newDF <- tbl(con, "source_data") %>%
        filter(grepl(regexQ, title, ignore.case = TRUE) | grepl(regexQ, body, ignore.case = TRUE)) %>%
        collect()

      # Record the time taken
      timing_end <- Sys.time()
      timing_duration <- timing_end - timing_start
      timing(timing_duration)

      data(newDF)

      dbDisconnect(con, shutdown = TRUE)
    }

  })

  output$tbl <- DT::renderDT({
    on.exit(tbl$hide())
    tbl$show()
    Sys.sleep(1)

    if (is.null(data())) {
      return(NULL)
    }

    DT::datatable(data(),
                  style = 'bootstrap',
                  rownames = FALSE,
                  extensions = c('Buttons', 'FixedHeader', 'KeyTable'),
                  plugins = 'natural',
                  options = list(dom = 'Bfrtip', pageLength = 1, buttons = list(
                    list(extend = "collection", buttons = c('csv', 'excel', 'pdf'),
                         text = "Download Current Page", filename = "page",
                         exportOptions = list(
                           modifier = list(page = "current")
                         )
                    ),
                    list(extend = "collection", buttons = c('csv', 'excel', 'pdf'),
                         text = "Download Full Results", filename = "data",
                         exportOptions = list(
                           modifier = list(page = "all")
                         )
                    )
                  )))


  })

  # Initialize modal
  modal <- modalDialog(
    title = "Database Connection Successful!",
    size = "l",
    easyClose = TRUE,
    footer = tagList(
      modalButton("Close")
    ),
    DT::DTOutput("modal_table")
  )

  # Observe event to open the modal when the "Show Modal" button is clicked
  observeEvent(input$create_button, {
    showModal(modal)

    output$modal_table <- DT::renderDT(server = FALSE, {

      DT::datatable(data(),
                    style = 'bootstrap',
                    rownames = FALSE,
                    extensions = c('Buttons', 'FixedHeader', 'KeyTable', 'Scroller'),
                    plugins = 'natural',
                    options = list(
                      deferRender = TRUE,
                      scrollY = 400,
                      scrollX = TRUE,
                      autoWidth = TRUE,
                      dom = 'Bfrtip',
                      pageLength = 1,
                      buttons = list(
                        list(
                          extend = "collection",
                          buttons = c('csv', 'excel', 'pdf'),
                          text = "Download Current Page",
                          filename = "page",
                          exportOptions = list(
                            modifier = list(page = "current")
                          )
                        ),
                        list(
                          extend = "collection",
                          buttons = c('csv', 'excel', 'pdf'),
                          text = "Download Full Results",
                          filename = "data",
                          exportOptions = list(
                            modifier = list(page = "all")
                          )
                        ))
                    ))
    })
  })

  observe({
    if (!is.null(timing())) {
      shinyalert("Timing Information", paste("Query execution time:\n", timing(),
                                             "\nNumber of rows: ", nrow(data())))
    }
  })

  observeEvent(input$reset_button, {

    session$reload()

  })

  timevisData <- data.frame(
    DataBase = c(rep("Additional", 50), rep("Core", 67)),
    Publisher_Name = c(
      "Herald Sun - Online", "Herald-Sun", "The Australian", "The Australian - Online",
      "The Sydney Morning Herald", "The Sydney Morning Herald - Online", "National Post",
      "The Globe and Mail", "The Globe and Mail", "The Toronto Sun",
      "Mumbai Mirror", "The Hindu Online", "The Hindu*", "The Times of India*",
      "La Jornada", "Metro Mexico", "Reforma", "Reforma.com", "Daily Sun Nigeria",
      "Nigerian Tribune", "The Nation", "Vanguard", "The Guardian",
      "Daily Independent Nigeria", "Daily Trust Nigeria", "Daily Sun", "Sunday Times",
      "The Star", "Mail & Guardian Online", "Sowetan", "20 Minutos", "El Mundo",
      "El País - English Edition", "El País - Nacional", "Elmundo.es", "Elpais.com",
      "Blick", "Blick Online", "Neue Zürcher Zeitung", "Tages Anzeiger",
      "Tages Anzeiger Online", "Cumhuriyet", "Hürriyet", "Hürriyet Daily News",
      "Milliyet", "Jewish Voice", "Asian Image", "The Haitian Times",
      "Radio Ambulante", "Code Switch", "Die Welt", "Süddeutsche Zeitung",
      "WELT online", "ARD Transkripte", "Bayerisches Fernsehen Transkripte",
      "bild.de", "BILD Plus", "ARD Alpha Transkripte", "Radio Bremen TV Transkripte",
      "MDR Transkripte", "NDR Transkripte", "Nürnberger Nachrichten", "Ostsee-Zeitung",
      "Ostsee-Zeitung Online", "RBB Transkripte", "RTL Transkripte",
      "Saarbrücker Zeitung", "Sat.1 Transkripte", "SR Fernsehen Transkripte",
      "Der Tagesspiegel Online", "Der Tagesspiegel", "Thüringer Allgemeine",
      "Weser Kurier", "BILD", "Gazeta.pl", "Gazeta Wyborcza & Wyborcza.pl",
      "Rzeczpospolita", "Fakt", "Fakt", "The Daily Telegraph", "The Guardian",
      "Guardian.co.uk", "The Telegraph Online", "Evening Times", "Liverpool Echo",
      "liverpoolecho.co.uk", "Bournemouth Echo", "The Northern Echo",
      "Evening Standard", "Evening Standard Online", "thesun.co.uk", "The Sun",
      "Ballymoney & Moyle Times", "The Wall Street Journal", "New York Post",
      "The Washington Post", "Washington Post.com", "The Wall Street Journal Online",
      "The Atlanta Journal - Constitution", "Deseret News", "Las Vegas Sun",
      "Star-Tribune", "PBS: PBS NewsHour", "NBC News: Nightly News",
      "The Philadelphia Inquirer", "The Santa Fe New Mexican", "St. Louis Post-Dispatch",
      "Tampa Bay Times", "Times of Northwest Indiana", "kabeleins Transkripte",
      "ProSieben Transkripte", "ZDF Transkripte", "Dziennik Gazeta Prawna",
      "Dziennik Gazeta Prawna Online", "MSNBC: The Rachel Maddow Show",
      "CNN: Anderson Cooper 360°", "Fox News Channel: Tucker Carlson Tonight"
    ),
    Country = c(rep("Australia", 6), rep("Canada", 4), rep("India", 4), rep("Mexico", 4),
                rep("Nigeria", 7), rep("South Africa", 5), rep("Spain", 6),
                rep("Switzerland", 5), rep("Turkey", 4), "Germany","United Kingdom",
                rep("United States", 3), rep("Germany", 24), rep("Poland", 5),
                rep("United Kingdom", 14), rep("United States", 16), rep("Germany", 3),
                rep("Poland", 2), rep("United States", 3)),
    Start_Date = c(rep("2012-01-01", 18), rep("2015-01-01", 7), rep("2012-01-01", 20),
                   rep("2015-01-01", 5), rep("2002-01-01", 3), rep("2012-01-01", 21),
                   rep("2002-01-01", 3), rep("2012-01-01", 2), rep("2002-01-01", 4),
                   rep("2012-01-01", 10), "2002-01-01", "2012-01-01",
                   rep("2002-01-01", 3), rep("2012-01-01", 14), rep("2002-01-01", 2),
                   rep("2012-01-01", 3)),
    End_Date = c(rep("2021-12-31", 117))
  )


  output$tbl_names <- DT::renderDT(server = FALSE,{

    DT::datatable(timevisData,
                  extensions = c("SearchPanes", "Select"),
                  options = list(dom = "Ptip")
    ) |>
      formatStyle(
        'DataBase',
        backgroundColor = styleEqual(
          unique(timevisData$DataBase), c('#e8f4f8', '#d2f8d2')
        )
      )


  })

}
