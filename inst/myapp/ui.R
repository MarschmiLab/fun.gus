ui <- fluidPage(

  # Application title
  titlePanel("Convert Your Well Plate Map To Long"),
  # Show plot
  mainPanel(
    titlePanel("Manually add values here"),
    DTOutput("my_datatable"),
    titlePanel("Or copy and paste from Excel/Google Sheets here"),
    textAreaInput("pasted","Only select values within your plate map, not headers or row names"),
    dataTableOutput("my_pasted"),
    titlePanel("Preview converted data"),
    dataTableOutput("my_longtable"),
    titlePanel("Export your long data"),
    downloadButton(outputId = "csv", "CSV"),
    downloadButton(outputId = "txt", "TXT")
  )
)
