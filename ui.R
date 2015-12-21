
library(shiny)

shinyUI(
        pageWithSidebar(
                # Application title
                headerPanel("Forecast the Cost of Thanksgiving Dinner Using ARIMA"),
                
                sidebarPanel(
                        img(src="iStock_000017775426XSmall_ThanksgivingDinner.jpg", height = '33%', width = '100%'),
                        tags$hr(style='height:2px; border-width:0; color:gray; background-color:gray'),
                        radioButtons("trans", label = h3("Data Transformation"),
                                            choices = list("None" = 1, "Log" = 2,
                                            "Square Root" = 3),selected = 1),
                        tags$hr(style='height:2px; border-width:0; color:gray; background-color:gray'),
                        h3('Select Order of Model Components'),
                        numericInput('ar', 'Autoregressive Component (0-5)', 0, min = 0, max = 5, step = 1),
                        numericInput('i', 'Integrative Component - Differencing (0-2)', 0, min = 0, max = 2, step = 1),
                        numericInput('ma', 'Moving Average Component (0-5)', 0, min = 0, max = 5, step = 1),
                        actionButton('fcstButton', 'Forecast'),
                        tags$hr(style='height:2px; border-width:0; color:gray; background-color:gray'),
                        h3('Instructions'),
                        p("Step 1: Identification"),
                        p("        ?"),
                        p("Step 2: Estimation"),
                        p("        ?"),
                        p("Step 3: Diagnostic Checking"),
                        p("        ?"),
                        p("Step 4: Forecast"),
                        p("        ?")
                        ),
                

                
                mainPanel(
                        #tags$hr(style='height:2px; border-width:0; color:gray; background-color:gray'),
                        h3('Identification', style='color:white; background-color:darkorange'),
                        plotOutput('newTS'),
                        #tags$hr(style='height:2px; border-width:0; color:gray; background-color:gray'),
                        h3('Estimation', style='color:white; background-color:darkorange'),
                        plotOutput('newARIMA'),
                        #fluidRow(
                        #        column(6, tableOutput('table')),
                        #        column(5, tableOutput('table2'))
                        #),
                        tableOutput('table'),
                        #tags$hr(style='height:2px; border-width:0; color:gray; background-color:gray'),
                        h3('Diagnostic Checking', style='color:white; background-color:darkorange'),
                        plotOutput('newCORREL'),
                        h3('Forecast', style='color:white; background-color:darkorange'),
                        plotOutput('newForecast'),
                        tableOutput('table3')
                        )
                
                )
        
        )