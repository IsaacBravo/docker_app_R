pacman::p_load(shiny, DBI, dbplyr, shinyjs, shinyalert, dplyr, shinyBS,
               spsComps, shinyWidgets, shinycssloaders, htmltools, DT, stringr)

ui <- navbarPage(

  theme = shinythemes::shinytheme("flatly"),
  ###############################################.
  ## Header ----
  ###############################################.

  "Database Management",

  ###############################################.
  ## Sidebar & Data Panel ----
  ###############################################.

  tabPanel("Home", icon = icon("home"), value = "home",
           tags$head(
             tags$script(src = "https://platform.twitter.com/widgets.js", charset = "utf-8"),
             tags$link(href = "https://fonts.googleapis.com/css?family=Roboto+Mono", rel = "stylesheet"),
             tags$style(HTML('
      * {
        font-family: Roboto Mono;
        font-size: 100%;
      }
      #sidebar {
         background-color: #fff;
         border: 0px;
      }
      .rt-th {
        display: none;
      }
      .rt-noData {
        display: none;
      }
      .rt-pagination-nav {
        float: left;
        width: 100%;
      }
    '))),

    fluidRow(
      column(1,  style = "width: 5px;"),
      column(11,
             h3("Welcome to the Database Management Shiny App.", class = "data-main-title"),
             hr(),
             p(
               br(),
               "This application aims to access the project's database remotely: 'The Media Portrayal of Majority and Minority Groups'. The users intended to use this application are the project team members.To review more information about this project. Please check the official project website, see ",
               a("here.", href = "https://www.gov.sot.tum.de/gov/junior-groups/the-media-portrayal-of-majority-and-minority-groups/",
                 target = "_blank",
                 class = "here-pop-up",
                 id = "here"
               )
             ),
             br()
      )),
    fluidRow(
      column(1,  style = "width: 5px;"),
      column(11,
             h3("Features:"),
             hr(),
             p("The creation of this application was possible thanks to the use of the cloud servers of the Leibniz-Rechenzentrum ",  a("- (LRZ).", href = "https://www.lrz.de/", target = "_blank", class = "here-pop-up", id = "here"), "The data related to the project was hosted on these servers, and by using a Docker container this shiny application is connected to deliver the data required by the user."),
             p(
               "Explore the key features of the Database Management Shiny App:",
               tags$ul(
                 id = "wellPanelId2",
                 class = "custom-well-panel-home1",
                 br(),
                 tags$li(strong("Setting up database access:"), "Easily configure and set up your database connection."),
                 tags$li(strong("Guided Search:"), "Perform a targeted search in all news data based on keywords or source."),
                 tags$li(strong("Choose Date Range:"), "Filter data by selecting a specific date range."),
                 tags$li(strong("Source Search:"), "Search based on source name (periodicals), based on database type. For this there are two databases (Core and Additional)."),
                 tags$li(strong("Run Query:"), "Execute custom queries and create tables with the click of a button."),
                 tags$li(strong("Table Results:"), "View and export the results of your queries in an interactive table."),
                 tags$li(strong("Text Analizer:"), "The app is connected to another web interface that allows the user to perform different analyses with the downloaded data."),
                 br()
               ),
               hr())
      )),

    fluidRow(
      column(1,  style = "width: 5px;"),
      column(11,
             h3("Rules of Use:"),
             hr(),
             p(
               "The following are some rules of use for extracting data from the database:",
               tags$ol(
                 id = "wellPanelId2",
                 class = "custom-well-panel-home1",
                 br(),
                 tags$li("First the user must enter in 'Guided Search' the keywords that will be used to filter the data. The user can also select whether the keywords entered are case sensitive or considered wildcard."),
                 tags$li("Then the user must select the date range to be covered. For this field, and in order to reduce waiting times for data access, it is recommended to select between 1 to 2 years per source name."),
                 tags$li("Later, to generate the table the user must select the database and the and source code. Then click on the 'Create Table' button."),
                 tags$li("To generate a new data table, the user must first click on the 'Reset' button, and after completing point 1 of this list. "),
                 br(),
                 p(icon("flag"), strong("Due to the time required to extract the data. It is recommended that the user access and download the data, using the combination 'Keywords' + '1 Year' + '1 Source Code'."))
               ),
               hr()
             )
      ))
  ),



  tabPanel("Main Panel", icon = icon("dashboard"), value = "table",


           fluidPage(

             tags$style(

               HTML(".custom-well-panel-home1 {
    color: #2E3E51; /* Text color: #7D8A8B */
    text-align: left; /* Align left */
    border: 1px solid #EDEDED; /* Border color: #EDEDED */
    background: #F5F5F5; /* Transparent background: #ECF0F1 */
    border-radius: 10px; /* Rounded corners */
    font-size: 16px; /* Adjust the font size as needed */
    min-height: 110px; /* Set the desired height in pixels */
    font-family: Roboto Mono;
  }"),
  HTML(".custom-well-panel, .custom-well-panel2, .custom-well-panel3, .custom-well-panel4 {
    color: #2E3E51; /* Text color: #7D8A8B */
    text-align: left; /* Align left */
    border: 1px solid #EDEDED; /* Border color: #EDEDED */
    background: transparent; /* Transparent background: #ECF0F1 */
    border-radius: 10px; /* Rounded corners */
    font-size: 16px; /* Adjust the font size as needed */
    min-height: 110px; /* Set the desired height in pixels */
    font-family: Roboto Mono;
  }"),
  HTML(".run-query-panel {
    color: #2E3E51; /* Text color: #7D8A8B */
    text-align: left; /* Align left */
    border: 1px solid white; /* Border color: #EDEDED */
    background: transparent; /* Transparent background: #ECF0F1 */
    border-radius: 10px; /* Rounded corners */
    font-size: 16px; /* Adjust the font size as needed */
    min-height: 110px; /* Set the desired height in pixels */
        display: flex; /* Enable flexbox layout */
    flex-direction: column; /* Arrange items vertically */
    justify-content: center; /* Center items vertically */
    align-items: center; /* Center items horizontally */
    font-family: Roboto Mono;
  }"),
  HTML(".run-query-panel > .shiny-input-container {
    margin: 10px; /* Add space around the input container (buttons) */
  }"),
  HTML(".custom-h4 {
    font-weight: bold; /* Make h3 bold */
    font-family: Roboto Mono;
  }"),

  HTML(".custom-h5 {
    font-weight: bold; /* Make h3 bold */
    color: white; /* Text color: #7D8A8B */
    font-family: Roboto Mono;
  }"),
  HTML("
    .custom-div {
      display: flex;
      align-items: center; /* Center vertically */
    }"),
  HTML("
    code {
      color: white;
      background-color: #41BC9C;
      padding: 2px;
      font-size: 105%;
    }"),
  HTML(".custom-button {
    width: 100%; /* Set the width to a fixed value or percentage */
  }")
             ),

  fluidRow(
    column(8,
           div(
             h4("Setting up database access", class = "custom-h4")
           ))),

  hr(),

  fluidRow(
    div(
      column(4,
             div(
               h4("Guided Search", icon("newspaper"), class = "custom-h4"),
               wellPanel(
                 id = "wellPanelId2",
                 class = "custom-well-panel2",
                 fluidRow(column(12, textInput("filter_regex", "Search in all News for:", placeholder = "Enter keywords or source"))),
                 checkboxInput("checkbox1", label = "Ignore case", value = TRUE),
                 checkboxInput("checkbox2", label = "Wildcard", value = TRUE),
               )
             )),
      column(4,
             div(
               h4("Choose Date Range", icon("clock"), class = "custom-h4"),
               wellPanel(
                 id = "wellPanelId3",
                 class = "custom-well-panel3",
                 fluidRow(column(12,   dateRangeInput("daterange1", "Date range:",
                                                      start = "2021-01-01",
                                                      end   = "2022-01-01"))),
               ))),
      column(4,
             div(
               h4("Run Query", icon("cloud"), class = "custom-h4"),
               fluidRow(
                 class = "run-query-panel",

                 column(2),
                 column(5, actionButton("create_button", p("Create Table", icon("play")), class = "custom-button"),
                        tags$div(style = "margin-top: 10px;")),
                 column(5, actionButton("reset_button", p("Reset", icon("refresh")), class = "custom-button")),
                 column(9,
                        p(
                          br(),
                          "If you want analyze the data that you just collected, check ",
                          a("here!", href = "https://github.com/IsaacBravo/ShinyDB",
                            target = "_blank",
                            class = "here-pop-up",
                            id = "here"
                          ), icon("calculator"), icon("chart-line"), icon("chart-area"), icon("chart-pie")
                        )
                 )



               )
             ))
    )
  ),

  # fluidRow(
  #   div(
  #     column(4,
  #            div(
  #              h4("Source Search", class = "custom-h4"),
  #              wellPanel(
  #                id = "wellPanelId2",
  #                class = "custom-well-panel2",
  #                fluidRow(column(12,
  #
  #                                textInput("filter_code", "Search in source code for:", placeholder = "Enter source code")
  #                )))))
  #   )),


  fluidRow(
    div(
      column(4,
             div(
               h4("Data Base Search", icon("database"), class = "custom-h4"),
               wellPanel(
                 id = "wellPanelId2",
                 class = "custom-well-panel2",
                 fluidRow(column(12,
                                 selectInput("filter_db", "Select Data Base", c(Core = "core", Additional = "additional"), selected = FALSE,
                                             multiple = FALSE, selectize = FALSE, size = 2),
                                 conditionalPanel(
                                   condition = "input.filter_db == 'core'",
                                   selectInput("filter_code_core", "Search in source name for:",
                                               c("Nürnberger Nachrichten", "Rzeczpospolita", "Thüringer Allgemeine",
                                                 "RBB Transkripte", "Bournemouth Echo", "The Atlanta Journal - Constitution",
                                                 "Evening Standard", "The Sun", "Evening Standard Online",
                                                 "Gazeta Wyborcza & Wyborcza.pl", "Saarbrücker Zeitung",
                                                 "The Wall Street Journal", "London Evening Standard Online",
                                                 "NBC News: Nightly News", "RTL Transkripte", "The Guardian", "The Guardian",
                                                 "Die Welt", "The Wall Street Journal Online", "The Telegraph Online",
                                                 "The Wall Street Journal", "ARD Transkripte", "Radio Bremen TV Transkripte",
                                                 "Guardian.co.uk", "The Santa Fe New Mexican", "BILD Plus",
                                                 "Liverpool Echo", "SR Fernsehen Transkripte", "The Philadelphia Inquirer",
                                                 "Las Vegas Sun", "BR Alpha Transkripte", "Süddeutsche Zeitung",
                                                 "Der Tagesspiegel", "The Wall Street Journal Online", "Fakt",
                                                 "Tampa Bay Times", "Times of Northwest Indiana",
                                                 "Ballymoney & Moyle Times", "The Guardian", "WELT online",
                                                 "The Daily Telegraph", "Süddeutsche Zeitung", "Fakt", "bild.de",
                                                 "Star-Tribune", "The Northern Echo", "Evening Times", "Deseret News",
                                                 "ARD Alpha Transkripte", "Sat.1 Transkripte", "The Wall Street Journal",
                                                 "The Washington Post", "Gazeta Wyborcza", "Ostsee-Zeitung",
                                                 "Washington Post.com", "Der Tagesspiegel Online", "Gazeta.pl",
                                                 "Telegraph.co.uk", "The Wall Street Journal Online", "thesun.co.uk",
                                                 "New York Post", "Bayerisches Fernsehen Transkripte", "Weser Kurier",
                                                 "Ostsee-Zeitung Online", "liverpoolecho.co.uk", "St. Louis Post-Dispatch",
                                                 "London Evening Standard", "Guardian Unlimited", "BILD",
                                                 "MDR Transkripte", "The Washington Post", "NDR Transkripte",
                                                 "PBS: PBS NewsHour")
                                   )),
                                 conditionalPanel(
                                   condition = "input.filter_db == 'additional'",
                                   selectInput("filter_code_additional", "Search in source name for:",
                                               c("Herald Sun - Online", "Herald-Sun", "The Australian", "The Australian - Online",
                                                 "The Sydney Morning Herald", "The Sydney Morning Herald - Online", "National Post",
                                                 "The Globe and Mail", "The Globe and Mail", "The Toronto Sun", "Mumbai Mirror",
                                                 "The Hindu Online", "The Hindu*", "The Times of India*", "La Jornada",
                                                 "Metro Mexico", "Reforma", "Reforma.com", "Daily Sun Nigeria", "Nigerian Tribune",
                                                 "The Nation", "Vanguard", "The Guardian", "Daily Independent Nigeria",
                                                 "Daily Trust Nigeria", "Daily Sun", "Sunday Times", "The Star",
                                                 "Mail & Guardian Online", "Sowetan", "20 Minutos", "El Mundo",
                                                 "El País - English Edition", "El País - Nacional", "Elmundo.es",
                                                 "Elpais.com", "Blick", "Blick Online", "Neue Zürcher Zeitung", "Tages Anzeiger",
                                                 "Tages Anzeiger Online", "Cumhuriyet", "Hürriyet", "Hürriyet Daily News",
                                                 "Jewish Voice", "Asian Image","The Haitian Times","Radio Ambulante","Code Switch", "Milliyet")
                                   ))

                 )))))
    )),




  hr()
           )),

  tabPanel("About", icon = icon("info"), value = "info",
           fluidRow(
             column(1,  style = "width: 5px;"),
             column(11,
                    h3("About the Database Management Shiny App.", icon("database"),
                       class = "data-main-title"),
                    hr(),
                    p("This Shiny App is designed to help you manage and analyze data from your database efficiently. ",
                      "It provides a user-friendly interface to perform various tasks related to database access, guided search, and more."), p(
                        "If you want access to the repository of this package, see ",
                        a("here.", href = "https://github.com/IsaacBravo/ShinyNews",
                          target = "_blank",
                          class = "here-pop-up",
                          id = "here"
                        )),
                    hr(),
                    HTML(paste("<p>(Made by <a href='https://github.com/seankellyhp'>@Sean_Palicki</a>", icon("github"), paste("& <a href='https://github.com/IsaacBravo'>@Isaac_Bravo</a>", icon("github"),". Source code <a href='https://github.com/IsaacBravo/ShinyNews'>on GitHub</a>.)</p>")))
             ),
             br()
           ),
           fluidRow(
             column(1,  style = "width: 5px;"),
             column(11,
                    h3("Source Codes: ", icon("code"),
                       class = "data-main-title"),
                    hr(),
                    p("Here you can check the details on each publisher on our data based on:
                      Database, Country, and Start_Date"),
                    DT::DTOutput("tbl_names"))
           ))
)

