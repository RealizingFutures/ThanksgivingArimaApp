
library(shiny)

shinyUI(
        pageWithSidebar(
                # Application title
                headerPanel("Thanksgiving Dinner Cost Forecaster (Using ARIMA)"),
                
                sidebarPanel(
                        img(src="iStock_000017775426XSmall_ThanksgivingDinner.jpg", height = '33%', width = '100%'),
                        tags$hr(style='height:2px; border-width:0; color:gray; background-color:gray'),
                        radioButtons("trans", label = h3("Data Transformation"),
                                            choices = list("None" = 1, "Log" = 2,
                                            "Square Root" = 3),selected = 1),
                        tags$hr(style='height:2px; border-width:0; color:gray; background-color:gray'),
                        h3('Select Order of Model Components'),
                        numericInput('ar', 'Autoregressive Component (0-5)', 0, min = 0, max = 5, step = 1),
                        numericInput('i', 'Integrated Component - Differencing (0-2)', 0, min = 0, max = 2, step = 1),
                        numericInput('ma', 'Moving Average Component (0-5)', 0, min = 0, max = 5, step = 1),
                        actionButton('fcstButton', 'Forecast'),
                        tags$hr(style='height:2px; border-width:0; color:gray; background-color:gray')
                        ),
                

                
                mainPanel(
                        tabsetPanel(
                                tabPanel("Forecaster",
                                        h3('Identification', style='color:white; background-color:darkorange'),
                                        plotOutput('newTS'),
                                        h3('Estimation', style='color:white; background-color:darkorange'),
                                        plotOutput('newARIMA'),
                                        tableOutput('table'),
                                        h3('Diagnostic Checking', style='color:white; background-color:darkorange'),
                                        plotOutput('newCORREL'),
                                        h3('Forecast', style='color:white; background-color:darkorange'),
                                        plotOutput('newForecast'),
                                        tableOutput('table3')
                                ),
                                tabPanel("Instructions",
                                         h3('Instructions', style='color:white; background-color:darkorange'),
                                         p('The Thanksgiving Dinner Cost Forecaster provides the user with an app that 
                                                uses the ARIMA(autoregressive integrated moving averages) forecasting 
                                                method to make predictions about how the prices for this holiday feast 
                                                could change over the next 5 years.'),
                                         tags$div(
                                                 tags$ul(
                                                         tags$li('The tool lets a user select parameters, change these selections to 
                                                                try out different models, then test various model predictions 
                                                                against reality before forecasting the future.'),
                                                         tags$li('The app uses costs from 1986-2010 to build a model, applies the 
                                                                model to forecasts of the costs for 2011-2015, then compares 
                                                                these forecasts to the actual prices for those years.'),
                                                         tags$li('Once the user has the parameters set to their satisfaction they 
                                                                can use this chosen model to forecast the cost of Thanksgiving 
                                                                Dinner for 2016-2020,'),
                                                         tags$li('The app is laid out in the form of the Box-Jenkins ARIMA methodology 
                                                                for model selection, which is an iterative three step process of 
                                                                identification, estimation, and diagnostic checking.'),
                                                         tags$li('The data source for Thanksgiving Dinner prices is the American Farm 
                                                                Bureau Federation (AFBF), who have been collecting this data through an 
                                                                informal price survey since 1986.')
                                                 )
                                         ),

                                         h4('Identification'),
                                         tags$div(
                                                 tags$ul(
                                                         tags$li('In the Identification panel there is a time series plot of 
                                                                Thanksgiving Dinner and accompanying autocorrelograms of the 
                                                                autocorrelation function (ACF) and partial autocorrelation 
                                                                function (PACF).'),
                                                         tags$li('Select Data Transformation options in the left panel in order 
                                                                to preprocess the time series. Apply a log transformation or a 
                                                                square root transformation in order to make the data stationary.'),
                                                         tags$li('Change the parameters for the Integrated component (0-2) in 
                                                                order to difference the time series and detrend the data.'),
                                                         tags$li('If you are familiar with the Box-Jenkins methodology you may 
                                                                use the ACF and PACF to determine whether to use an AR model, 
                                                                an MA model, or a mixed model.')
                                                 )
                                         ),
                                         h4('Estimation'),
                                         tags$div(
                                                 tags$ul(
                                                         tags$li('Change the parameters for the Autoregressive component(0-5) to
                                                                indicate the order, or the amount of lagged time periods back to 
                                                                correlate prior observations with current observations.'),
                                                         tags$li('Change the parameters for the Moving Averages component (0-5) to
                                                                indicate the order of adaptation from past forecast errors 
                                                                to new forecasts.'),
                                                         tags$li('Consider the RMSE (root mean squared error) and the AIC 
                                                                 (Akaike information criterion) for measuring model fit, where
                                                                 the goal is to minimize the statistics.'),
                                                         tags$li('Consider the RMSE (root mean squared error) and the MAPE 
                                                                 (mean abosolute percent error) for measuring performance on
                                                                 a hold-out set of test data, where the goal is to minimize the
                                                                 statistics')
                                                 )
                                         ),
                                         h4('Diagnostic Checking'),
                                         tags$div(
                                                 tags$ul(
                                                         tags$li('Use the ACF and PACF plots of the model residuals to check
                                                                 how well the model fits the data.'),
                                                         tags$li('If the ACF or PACF show patterns in the residuals, then this
                                                                 suggests that there is still information available to 
                                                                 exploit and this may not be the best model.'),
                                                         tags$li('If the residuals have no patters and display a random distribution
                                                                 or white noise, then this suggests the model has captured all
                                                                 of the exploitable pattern in the data.'),
                                                         tags$li('Consider the residuals along with the RMSE, AIC, and MAPE 
                                                                 statistics shown on plot in the Estimation section.')
                                                 )
                                         ),
                                         h4('Forecast'),
                                         tags$div(
                                                 tags$ul(
                                                         tags$li('Once you have the parameters you think will make the best
                                                                 forecasts click the Forecast button.'),
                                                         tags$li('This will producee a forecast for the years 2016-2020 using 
                                                                 the selected parameters.')
                                                 )
                                         )
                                         
                                 )
                                        
                        )
                )
                
        )
        
)