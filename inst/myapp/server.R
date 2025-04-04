server <- function(input, output) {

  #initialize a blank dataframe
  v <- shiny::reactiveValues(data = {
    data.frame(matrix(rep("", 96), nrow = 8, ncol = 12))%>%
      dplyr::rename_with(~stringr::str_replace(string = ., pattern = "X",replacement = "Col"))%>%
      tibble::add_column(Row = LETTERS[1:8], .before = "Col1")
  })


  #output the datatable based on the dataframe (and make it editable)
  output$my_datatable <- DT::renderDT({
    DT::datatable(v$data, editable = TRUE)
  })

  df_table <- shiny::reactive({
    if(input$pasted != ''){
      df_table <- data.table::fread(paste(input$pasted, collapse = "\n"), header = FALSE, col.names = paste0("Col",1:12))
      df_table <- as.data.frame(df_table)
      df_table
    }
  })

  output$my_pasted <- DT::renderDataTable(df_table())

  #when there is any edit to a cell, write that edit to the initial dataframe
  #check to make sure it's positive, if not convert
  shiny::observeEvent(input$my_datatable_cell_edit, {
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

  long_data <- shiny::reactive({
    if(input$pasted == ''){
      v$data%>%
        tidyr::pivot_longer(cols = dplyr::starts_with("Col"), names_to = "Column", values_to = "SampleName")%>%
        dplyr::mutate(clean_col = stringr::str_remove(Column, "Col"),
               clean_col = stringr::str_pad(clean_col, width = 2, side = "left", pad = "0"),
               Well = paste0(Row, clean_col))%>%
        dplyr::arrange(clean_col)%>%
        dplyr::select(Well, SampleName)
    }else{
      v$data[1:8, 2:13] <- df_table()[1:8, 1:12]
      v$data%>%
        tidyr::pivot_longer(cols = dplyr::starts_with("Col"), names_to = "Column", values_to = "SampleName")%>%
        dplyr::mutate(clean_col = stringr::str_remove(Column, "Col"),
               clean_col = stringr::str_pad(clean_col, width = 2, side = "left", pad = "0"),
               Well = paste0(Row, clean_col))%>%
        dplyr::arrange(clean_col)%>%
        dplyr::select(Well, SampleName)
    }

  })

  output$my_longtable <- DT::renderDT({
    long_data()
  })

  output$csv<-shiny::downloadHandler(
    filename = function(){"Long_Well_Map.csv"},
    content = function(fname){
      readr::write_csv(long_data(),fname)
    }
  )
  output$txt<-shiny::downloadHandler(
    filename = function(){"Long_Well_Map.txt"},
    content = function(fname){
      readr::write_tsv(long_data(),fname)
    }
  )


}
