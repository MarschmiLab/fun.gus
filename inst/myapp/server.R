server <- function(input, output) {

  #initialize a blank dataframe
  v <- reactiveValues(data = {
    data.frame(matrix(rep("", 96), nrow = 8, ncol = 12))%>%
      rename_with(~str_replace(string = ., pattern = "X",replacement = "Col"))%>%
      add_column(Row = LETTERS[1:8], .before = "Col1")
  })


  #output the datatable based on the dataframe (and make it editable)
  output$my_datatable <- renderDT({
    DT::datatable(v$data, editable = TRUE)
  })

  df_table <- reactive({
    if(input$pasted != ''){
      df_table <- fread(paste(input$pasted, collapse = "\n"), header = FALSE, col.names = paste0("Col",1:12))
      df_table <- as.data.frame(df_table)
      df_table
    }
  })

  output$my_pasted <- renderDataTable(df_table())

  #when there is any edit to a cell, write that edit to the initial dataframe
  #check to make sure it's positive, if not convert
  observeEvent(input$my_datatable_cell_edit, {
    #get values
    info = input$my_datatable_cell_edit
    i = as.numeric(info$row)
    j = as.numeric(info$col)
    k = as.character(info$value)

    #write values to reactive
    v$data[i,j] <- k
  })

  #observeEvent(input$pasted != '', {
  #  v$data[1:8, 2:13] <- df_table()[1:8,1:12]
  #})

  long_data <- reactive({
    if(input$pasted == ''){
      v$data%>%
        pivot_longer(cols = starts_with("Col"), names_to = "Column", values_to = "SampleName")%>%
        mutate(clean_col = str_remove(Column, "Col"),
               clean_col = str_pad(clean_col, width = 2, side = "left", pad = "0"),
               Well = paste0(Row, clean_col))%>%
        arrange(clean_col)%>%
        select(Well, SampleName)
    }else{
      v$data[1:8, 2:13] <- df_table()[1:8, 1:12]
      v$data%>%
        pivot_longer(cols = starts_with("Col"), names_to = "Column", values_to = "SampleName")%>%
        mutate(clean_col = str_remove(Column, "Col"),
               clean_col = str_pad(clean_col, width = 2, side = "left", pad = "0"),
               Well = paste0(Row, clean_col))%>%
        arrange(clean_col)%>%
        select(Well, SampleName)
    }

  })

  output$my_longtable <- renderDT({
    long_data()
  })

  output$csv<-downloadHandler(
    filename = function(){"Long_Well_Map.csv"},
    content = function(fname){
      write_csv(long_data(),fname)
    }
  )
  output$txt<-downloadHandler(
    filename = function(){"Long_Well_Map.txt"},
    content = function(fname){
      write_tsv(long_data(),fname)
    }
  )


}
