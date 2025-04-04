ui <- shiny::fluidPage(

  # Application title
  shiny::titlePanel("Convert Your Well Plate Map To Long"),
  # Show plot
  shiny::mainPanel(
    shiny::titlePanel("Manually add values here"),
    DT::DTOutput("my_datatable"),
    shiny::titlePanel("Or copy and paste from Excel/Google Sheets here"),
    shiny::textAreaInput("pasted","Only select values within your plate map, not headers or row names"),
    shiny::dataTableOutput("my_pasted"),
    shiny::titlePanel("Preview converted data"),
    shiny::dataTableOutput("my_longtable"),
    shiny::titlePanel("Export your long data"),
    shiny::downloadButton(outputId = "csv", "CSV"),
    shiny::downloadButton(outputId = "txt", "TXT")
  )
)
