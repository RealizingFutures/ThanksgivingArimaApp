

## load Packages
library(shiny); library(XML); library(data.table); library(forecast); library(tseries)

## get Thanksgiving Dinner data from the American Farm Bureau Federation
fileUrl <- "http://www.fb.org/newsroom/news_article/369/"
doc <- htmlTreeParse(fileUrl, useInternal=TRUE)

## locate the XML that has the table data and begin filtering it
thanks.raw <- xpathApply(doc,"//td[@valign='top']", xmlValue)
thanks.raw[1:5] <- NULL

## loop through raw XML and extract the Thanksgiving Dinner price and year
Year <- NULL
date <- NULL
price <- NULL
x <- 1
while(thanks.raw[[x]]!="Item"){
        if(nchar(thanks.raw[[x]])==4) {
                Year = c(Year, thanks.raw[[x]])
                date = c(date, 
                         paste(thanks.raw[[x]], "-11-01", sep=""))
        } 
        if(nchar(thanks.raw[[x]])==6) {
                price = c(price, 
                          as.numeric(substr(thanks.raw[[x]], 2, 6)))
        }
        x <- x + 1
}

## create a date table with the thanksgiving dinner prices
thanks.prices <- data.table(date = as.Date(date), Year, 
        series_name = "Thanksgiving", value = price)

thanks.value <- thanks.prices[series_name == "Thanksgiving", c("Year", "value"), with=FALSE]
ts.thanks.value <- ts(thanks.value$value, c(as.numeric(thanks.value[1,Year]), 1), 
        c(as.numeric(thanks.value[nrow(thanks.value), Year]), 1), frequency = 1)

ts.all.thanks.value <- ts.thanks.value
ts.train.thanks.value <- window(ts.thanks.value, start = 1986, end = 2010)
ts.test.thanks.value <- window(ts.thanks.value, start = 2011)


thanksgivingARIMA <- function(ts.train, ar,i,ma,trans){
        
        ts.train <- if(trans == 1) {
                        ts.train      
                } else if(trans == 2) {
                        log(ts.train)
                } else sqrt(ts.train)
       
        model.arima.thanks.value <- arima(ts.train,  order = c(ar,i,ma), 
                seasonal = list(order = c(0,0,0), 1), method="ML")
        fcst.arima.thanks.value  <- forecast(model.arima.thanks.value, h=5)
        
        fcst.arima.thanks.value$x <- if(trans == 1) {
                fcst.arima.thanks.value$x      
        } else if(trans == 2) {
                exp(1)^fcst.arima.thanks.value$x
        } else fcst.arima.thanks.value$x^2
        
        fcst.arima.thanks.value$mean <- if(trans == 1) {
                fcst.arima.thanks.value$mean      
        } else if(trans == 2) {
                exp(1)^fcst.arima.thanks.value$mean
        } else fcst.arima.thanks.value$mean^2
        
        fcst.arima.thanks.value$lower <- if(trans == 1) {
                fcst.arima.thanks.value$lower      
        } else if(trans == 2) {
                exp(1)^fcst.arima.thanks.value$lower
        } else fcst.arima.thanks.value$lower^2
        
        fcst.arima.thanks.value$upper <- if(trans == 1) {
                fcst.arima.thanks.value$upper      
        } else if(trans == 2) {
                exp(1)^fcst.arima.thanks.value$upper
        } else fcst.arima.thanks.value$upper^2
        
        model.arima <- gsub(" ", "", fcst.arima.thanks.value$method, fixed = TRUE)  

        list.arima <<- list(forecast = fcst.arima.thanks.value, 
                training = ts.train, 
                testing = ts.test.thanks.value, 
                model = model.arima)    
}


shinyServer(
        function(input, output){
                         
                
                tARIMA <- reactive({thanksgivingARIMA(ts.train.thanks.value, as.numeric(input$ar), 
                as.numeric(input$i), as.numeric(input$ma), as.numeric(input$trans))}) 
                
                i <- reactive({as.numeric(input$i)})
                trans <- reactive({as.numeric(input$trans)})
                
                
                output$newTS <- renderPlot({
                        
                        ts.plot <- if(trans() == 1) {
                                tARIMA()$training      
                        } else if(trans() == 2) {
                                log(tARIMA()$training)
                        } else sqrt(tARIMA()$training)
                        
                        ts.plot <- if(i() == 0) {
                                ts.plot      
                                } else diff(ts.plot, i())
                        
                        par(mfrow = c(1,1), cex = 1, lwd = 3)
                        tsdisplay(ts.plot, col = "darkorange", 
                                  main = "The Cost of Thanksgiving Dinner - Time Series")
                })
                     
                output$newARIMA <- renderPlot({
                        
                        my.min <- min(tARIMA()$forecast$lower[,2], tARIMA()$forecast$x, 
                                      tARIMA()$testing[1:5]) - 1
                        my.max <- max(tARIMA()$forecast$upper[,2], tARIMA()$forecast$x, 
                                      tARIMA()$testing[1:5]) + 1
                        
                        par(mfrow = c(1,1), cex = 1, lwd = 3)
                        plot(tARIMA()$forecast,  col = "darkorange", ylim=c(my.min,my.max), 
                                     main = "The Cost of Thanksgiving Dinner - ARIMA Forecast", 
                                     xlab = "Year", 
                                     ylab = "Dollars")
                        
                                lines(tARIMA()$testing, col = "red" )
                        
                                usr <- par("usr") # get user coordinates
                                par(usr = c(0, 1, 0, 1))
                                legend(0.03, 0.87, c("Cost", "Forecast", "Hold-Out", "80% PI", "95% PI"),
                                       lty=c(1,1), lwd=c(3,3,3,3,3), , inset = .05,
                                       col=c("darkorange", "blue", "red", "darkgray", "lightgray"))
                                par(usr = usr) # restore original user coordinate
                                
                                ##data.unitRoot <- if(i() == 0) {
                                ##        tARIMA()$training[1:length(tARIMA()$training)] 
                                ##} else diff(tARIMA()$training[1:length(tARIMA()$training)], i())
                        
                                ##unitRoot <- kpss.test(data.unitRoot)
                                loglik <- tARIMA()$forecast$model$loglik
                                AIC <- tARIMA()$forecast$model$aic
                                accuracy.arima.thanks.value <- accuracy(tARIMA()$forecast, 
                                                                        tARIMA()$testing)
                                RMSE.train <- accuracy.arima.thanks.value[[1,2]]        
                                RMSE.test <- accuracy.arima.thanks.value[[2,2]]
                                MAPE.test <- accuracy.arima.thanks.value[[2,5]]
                
                                usr <- par("usr") # get user coordinates 
                                par(usr = c(0, 1, 0, 1))
                                text(0.22, 0.85, "ARIMA(p,d,q) Model:", adj = 0, font=4)
                                text(0.22, 0.79, tARIMA()$model, adj = 0)
                                text(0.22, 0.73, paste("RMSE: ", round(RMSE.train,2), sep=""), adj = 0)
                        
                                ##text(0.2, 0.67, paste("KPSS Unit Root: ", unitRoot, sep=""), adj = 0)
                                text(0.22, 0.67, paste("AIC: ", round(AIC,2), sep=""), adj = 0)
                                text(0.22, 0.60, "Accuracy on Hold-Out Actuals:", adj = 0, font=4)
                                text(0.22, 0.54, paste("RMSE: ", round(RMSE.test,2), sep=""), adj = 0)
                                text(0.22, 0.48, paste("MAPE: ", sprintf('%1.2f%%', round(MAPE.test,2)), sep=""), adj = 0)
                                text(0.55, 0.03, "Data: American Farm Bureau Federation", cex = 0.75, adj = 0)
                                par(usr = usr) # restore original user coordinate

                
                })
                
                output$table <- renderTable({
                        print(tARIMA()$forecast)
                })
                                            
                                            
                output$table2 <- renderTable({
                        accuracy.table <- data.table("Point Forecast" = tARIMA()$forecast$mean[1:5]
                                , "Hold-Out Actual" = tARIMA()$testing[1:5]
                                , "Error" = tARIMA()$testing[1:5] - tARIMA()$forecast$mean[1:5] 
                                , "APE" = sprintf('%1.2f%%', abs(100 * (tARIMA()$testing[1:5] - tARIMA()$forecast$mean[1:5]) 
                                                  / tARIMA()$testing[1:5]))
                        )

                        rownames(accuracy.table) <- c("2011","2012","2013","2014","2015")
                        accuracy.table
                })                          
                

                output$newCORREL <- renderPlot({
                        par(mfrow = c(1,2), cex = 1, lwd = 3)
                        acf(tARIMA()$forecast$residuals, main ="ACF", col = "darkorange")
                        pacf(tARIMA()$forecast$residuals, main ="PACF", col = "darkorange")
                        par(mfrow = c(1,1), cex = 1)
                })
                
                tARIMA2 <- eventReactive(input$fcstButton, {thanksgivingARIMA(ts.all.thanks.value, as.numeric(input$ar), 
                          as.numeric(input$i), as.numeric(input$ma), as.numeric(input$trans))})
                
                output$newForecast <- renderPlot({
                        
                        my.min <- min(tARIMA2()$forecast$lower[,2], tARIMA2()$forecast$x, 
                                      tARIMA2()$testing[1:5]) - 1
                        my.max <- max(tARIMA2()$forecast$upper[,2], tARIMA2()$forecast$x, 
                                      tARIMA2()$testing[1:5]) + 1
                        
                        par(mfrow = c(1,1), cex = 1, lwd = 3)
                        plot(tARIMA2()$forecast,  col = "darkorange", ylim=c(my.min,my.max), 
                             main = "The Cost of Thanksgiving Dinner - ARIMA Forecast", 
                             xlab = "Year", 
                             ylab = "Dollars")
                        
                        usr <- par("usr") # get user coordinates
                        par(usr = c(0, 1, 0, 1))
                        legend(0.03, 0.87, c("Cost", "Forecast", "80% PI", "95% PI"),
                               lty=c(1,1), lwd=c(3,3,3,3), , inset = .05,
                               col=c("darkorange", "blue", "darkgray", "lightgray"))
                        par(usr = usr) # restore original user coordinate
                        
                        loglik <- tARIMA2()$forecast$model$loglik
                        AIC <- tARIMA2()$forecast$model$aic
                        
                        usr <- par("usr") # get user coordinates 
                        par(usr = c(0, 1, 0, 1))
                        text(0.22, 0.85, "ARIMA(p,d,q) Model:", adj = 0, font=4)
                        text(0.22, 0.79, tARIMA2()$model, adj = 0)
                        #text(0.3, 0.73, paste("Log-Likelihood: ", round(loglik,2), sep=""), adj = 0)
                        text(0.22, 0.73, paste("AIC: ", round(AIC,2), sep=""), adj = 0)
                        text(0.55, 0.03, "Data: American Farm Bureau Federation", cex = 0.75, adj = 0)
                        par(usr = usr) # restore original user coordinate

                })
        
        
                output$table3 <- renderTable({
                        print(tARIMA2()$forecast)
                })
                

                
        }
)