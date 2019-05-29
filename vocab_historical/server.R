#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(feather)
library(shiny)

all_counts_df <- read_feather('all_counts.feather')
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$all_counts <- renderDataTable(all_counts_df)
  
})
