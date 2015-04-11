library(shiny)

shinyUI(fluidPage(
  titlePanel("Sort Through OpenTable Brunch Options"),
  sidebarLayout(
    sidebarPanel(
      helpText("Find a listing of Sunday Brunch options from open table.  Copy the web address and paste it below."),
      textInput(
        inputId = "url",
        label = "OpenTable Web Address", 
        value = "paste the address here"),
      helpText("After the list of checkboxes loads, follow the directions and then move to the next tab.")
    ), #end of sidebarPanel
    mainPanel(tabsetPanel(
      tabPanel("Regions", uiOutput("Regions")),
      tabPanel("Locations", uiOutput("Locations")),
      tabPanel("Fare", uiOutput("Fares")),
      tabPanel("Beverages", uiOutput("Beverages")),
      tabPanel("Results", uiOutput("Results"))
    )) #end of mainPanel
  ) #end of sidebarLayout
)) #end of shinyUI
