library(shiny)
source("functions.R")

shinyServer(function(input, output) {
  
  DiningSet =  reactive(
    if(is.null(input$url)){return()
    } else if (input$url == "paste the address here"){return()
    } else if (input$url == ""){return()
    } else {GetPage(input$url)})
  
  DiningSet1 = reactive(
    if(is.null(DiningSet)){return()
    } else {x = SubSet1(DiningSet(), input$LocationInput)
            return(x)})
  
  DiningSet2 = reactive(
    if(is.null(DiningSet1)){return()
    } else {x = SubSet2(DiningSet1(), input$FareInput)
            return(x)})
  
  
  DiningSet3 = reactive(
    if(is.null(DiningSet2)){return()
    } else {x = SubSet3(DiningSet2(), input$BeverageInput)
            return(x)})
  
  
  output$Locations = renderUI(
    if(is.null(DiningSet())){return()
    } else checkboxGroupInput(
      inputId = "LocationInput", 
      label = "Which Locations do you want to use?", 
      choices = unique(DiningSet()$place), 
      selected = unique(DiningSet()$place)
    )
  )
  
  output$Fares = renderUI(
    if(is.null(DiningSet1())){return()
    } else {checkboxGroupInput(
              inputId = "FareInput", 
              label = "Which types of food interest you?", 
              choices = unique(DiningSet1()$type), 
              selected = unique(DiningSet1()$type))}
  )
  
  output$Beverages = renderUI(
    if(is.null(DiningSet2())){return()
    } else checkboxInput(
      inputId = "BeverageInput", 
      label = "Check the box to restict the results to places with unlimited or bottomless in the description."
    )
  )
  
  output$Results = renderTable(
    expr = DiningSet3()
  )
  
  
})
