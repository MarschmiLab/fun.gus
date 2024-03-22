#' Interactively Define Gates for Flow Cytometry Flow Set
#'
#' This function launches a Shiny app wherein you can interactively define gates for a flow cytometry flow set. Produce your flowset using flowCore::read.flowSet(). Use drop-down menus to select axes for your plots. Click on the plots to draw your gate. Use the Remove Point button to remove vertices, in reverse order that you created them. The Gate Name text input will determine the name of the polygon gate you will create; as such it must follow R guidelines for naming objects. Use Export button to save the gave as an .RData file, which will create a polygonGate as defined by flowCore.
#' @param flo_set A flow set produced using `flowCore::read.flowSet()`
#' @returns Opens a a shiny app where you can interactively define gates and export them as an .RData object.
#'
#' @importFrom flowCore flowSet_to_list parameters pData exprs polygonGate
#' @importFrom dplyr pull mutate
#' @importFrom stringr str_replace_all
#' @importFrom purrr map2 reduce
#' @importFrom magrittr %>%
#' @importFrom tibble tibble add_row
#' @import ggplot2
#' @import shiny
#'
#' @export
MakeInteractiveGates <- function(flo_set) {


  flo_frames <- flowSet_to_list(flo_set)

  params <- parameters(flo_frames[[1]]) %>% pData %>% pull(name) %>%
    str_replace_all("-",".")%>%
    setNames(nm = NULL)

  flo_names <- names(flo_frames)

  full_data <- map2(flo_frames, flo_names, \(flo, flo_n)flo %>%
                      exprs() %>%
                      data.frame() %>%
                      mutate(sample = flo_n)) %>%
    reduce(rbind)


  ui <- fluidPage(
    fluidRow(
      column(plotOutput("plot1", click = "plot_click"), width = 8),
      column(tableOutput("table"), width = 4)
    ),
    fluidRow(
      column(selectInput("plot_type", label = "Choose Plot Type", choices = c("Cloud","Histogram")), width = 2),
      column(selectInput("x_axis", label = "X Axis", choices = params), width = 2),
      column(selectInput("y_axis", label = "Y Axis", choices = params), width = 2),
      column(selectInput("trans", label = "Transformation", choices = c("identity","log10")), width = 2),
      column(textInput("gate", "Gate Name", value = "new_gate"), width = 2)
    ),
    fluidRow(
      column(actionButton("remove_point", "Remove Last Point"), width = 2),
      column(actionButton("export", "Export Gate"), width = 2)
    )


  )

  server <- function(input, output) {
    coords <- reactiveVal(value = tibble(x = numeric(), y = numeric()))

    observeEvent(input$plot_click, {
      add_row(coords(),
              x = isolate(input$plot_click$x),
              y = isolate(input$plot_click$y),
      ) %>% coords()
    })

    observeEvent(input$remove_point, {
      head(coords(), -1) %>%
        coords()
    })

    toListen <- reactive({
      list(input$x_axis,input$y_axis)
    })

    observeEvent(toListen(), {
      head(coords(), 0) %>%
        coords()
    })

    output$plot1 <- renderPlot({
      cor_len <- length(coords()$x)
      if(input$plot_type %in% "Cloud"){
        ggplot(full_data, aes_string(x = input$x_axis, y = input$y_axis)) +
          scale_x_continuous(expand = expansion(mult = .2), transform = input$trans) +
          scale_y_continuous(expand = expansion(mult = .2), transform = input$trans) +
          geom_hex(bins = 100) +
          facet_wrap(~sample) +
          scale_fill_viridis_c(trans = "log10", option = "G")+
          theme_classic() +
          annotate(geom = "point", color = "red", x = coords()$x, y = coords()$y) +
          annotate(geom = "polygon", x = coords()$x[chull(coords()$x,coords()$y)], y = coords()$y[chull(coords()$x,coords()$y)], fill = NA, color = "red")
      }else{
        ggplot(full_data, aes_string(x = input$x_axis)) +
          scale_x_continuous(expand = expansion(mult = 0), transform = input$trans) +
          geom_histogram(bins = 100) +
          facet_wrap(~sample) +
          theme_classic() +
          geom_vline(xintercept = coords()$x[ifelse(cor_len>=1, cor_len, -Inf)], color = "red") +
          geom_vline(xintercept = coords()$x[ifelse(cor_len>=2, cor_len - 1, -Inf)], color = "red")
      }
    })

    output$table <- renderTable(coords())

    observeEvent(input$export, {

      if(input$plot_type %in% "Cloud"){
        gate_matrix <- matrix(c(coords()$x, coords()$y), byrow = FALSE, ncol = 2)

        colnames(gate_matrix) <- c(str_replace(input$x_axis, "\\.", "-"),str_replace(input$y_axis, "\\.", "-"))

        gate <- polygonGate(filterId = input$gate, .gate = gate_matrix)

        assign(input$gate, gate)

        save(list = input$gate, file = file.choose(new = TRUE))
      }else{
        gate_matrix <- matrix(tail(coords()$x, 2), ncol = 1)
        colnames(gate_matrix) <- str_replace(input$x_axis, "\\.", "-")
        gate <- rectangleGate(filterId = input$gate, .gate = gate_matrix)      #
        assign(input$gate, gate)
        #
        save(list = input$gate, file = file.choose(new = TRUE))
      }
    }
    )

  }

  shinyApp(ui, server)

}
