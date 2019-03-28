#install.packages("shinydashboard")
#install.packages("shinycssloaders")
library(dplyr)
library(haven)
library(shiny)
library(ggplot2)
library(shinycssloaders)
library(shiny)
library(shinydashboard)
library(plotly)
library(ggrepel)



options(shiny.maxRequestSize=30*1024^2)
getwd()
#load("basetable.RData")

server <- function(input, output,session) {
Fifa1<-Fifa[1:1000,1:10] 
  
  #basetable <- read.csv("./basetable.csv", stringsAsFactors = F)
  
  output$table <- renderDataTable({
    
    if(is.null(Fifa1))
    {return ()}
    data=Fifa1
    data
  },options = list(searching = FALSE))
  
  
  ###########Graph 1############
  output$graph1<- renderPlotly({
    output=SquadValue()
    output
  })
  
  ###########Graph 2############
  output$graph2<-renderPlotly({
    output=TopWage()
    output
    
  })
  
  ###########Graph 3############
  output$graph3<-renderPlotly({
    output=SuperStars()
    output
  })
  

  
  ###########Graph 5############
  output$graph4<-renderPlotly({
    new<-YoungestSquad()
    new
  })
  

  ###########Graph 7############
  output$graph5<-renderPlotly({
    new<-Playerjersey()
    new
  })
  
  ###########Graph 8############
  output$graph6<-renderDataTable({
    new<-BestFreekickers()
    new
  })
  
  ###########Graph 9############
  output$graph7<-renderDataTable({
    new<-MostUnfit()
    new
  })
  output$graph8<-renderPlotly({
    new<-VariationAge()
    new
  })
  
  
  ########### Squad Value in Millions ##############
  SquadValue<-reactive({
    
    Fifa %>%
      group_by(Club)%>%
      summarise(Club.Squad.Value = round(sum(Value)/1000000))%>%
      arrange(-Club.Squad.Value)%>%
      head(10)%>%
      ggplot(aes(x = as.factor(Club) %>%
                   fct_reorder(Club.Squad.Value), y = Club.Squad.Value, label = Club.Squad.Value))+
      geom_text(hjust = 0.01,inherit.aes = T, position = "identity")+
      geom_bar(stat = "identity", fill = "violetred1")+
      coord_flip()+
      xlab("Club")+
      ylab("Squad Value in Million")
    
  })
  
  
  
  
  
  
  
  
  ########### Top Wage Bills ##############
  TopWage<-reactive({
    Fifa %>%
      group_by(Club)%>%
      summarise(Total.Wage = round(sum(Wage)/1000000, digits =2))%>%
      arrange(-Total.Wage)%>%
      head(10)%>%
      ggplot(aes(x = as.factor(Club) %>%
                   fct_reorder(Total.Wage), y = Total.Wage, label = Total.Wage))+
      geom_text(hjust = 0.01,inherit.aes = T, position = "identity")+
      geom_bar(stat = "identity", fill = "violetred1")+
      coord_flip()+
      xlab("Club")+
      ylab("Squad Wages in Million")
    
    
  })
  
  ###########Superstars in FIFA  ##############
  SuperStars<-reactive({
    Fifa %>%
      mutate(Superstar = ifelse(Overall> 86, "Superstar","Non - Superstar"))%>%
      group_by(Club)%>%
      filter(Superstar=="Superstar")%>%
      summarise(Player.Count = n())%>%
      arrange(-Player.Count)%>%
      ggplot(aes(x = as.factor(Club) %>%
                   fct_reorder(Player.Count), y = Player.Count, label = Player.Count))+
      geom_text(hjust = 0.01,inherit.aes = T, position = "identity")+
      geom_bar(stat = "identity", fill = "palegreen2")+
      coord_flip()+
      xlab("Club")+
      ylab("Number of Superstars")
    
  })
  
  
  
  
  
  
  ###########Age Distribution amongst the Top Valued Clubs ##############
  getage<-reactive({
    Most.Valued.Clubs <- Fifa %>%
      group_by(Club)%>%
      summarise(Club.Squad.Value = round(sum(Value)/1000000))%>%
      arrange(-Club.Squad.Value)%>%
      head(10)
    
    Player.List <- list()
    
    for (i in 1:nrow(Most.Valued.Clubs)){
      temp.data <-  Fifa%>%
        filter(Club == Most.Valued.Clubs[[1]][i]) 
      
      Player.List[[i]] <- temp.data
    }
    
    data <- lapply(Player.List, as.data.frame) %>% bind_rows()
    
    data$Club <- as.factor(data$Club)
    
    ggplot(data, aes(x = Club ,y = Age, fill = Club)) +
      geom_violin(trim = F)+
      geom_boxplot(width = 0.1)+
      theme(axis.text.x = element_text(angle = 90), legend.position = "none")+
      ylab("Age distribution amongst Clubs")
    
  })
  
  
  
  
  
  
  
  
  
  ####Clubs with the youngest Squad####
  YoungestSquad<-reactive({
    
    Fifa %>%
      group_by(Club)%>%
      summarise(Club.Avg.Age = round(sum(Age)/length(Age),digits = 2))%>%
      arrange(Club.Avg.Age)%>%
      head(10)%>%
      ggplot(aes(x = as.factor(Club) %>%
                   fct_reorder(Club.Avg.Age), y = Club.Avg.Age, label = Club.Avg.Age))+
      geom_bar(stat = "identity", fill = "turquoise4")+
      geom_text(inherit.aes = T, nudge_y = 0.5)+
      xlab("Club")+
      theme(axis.text.x = element_text(angle = 90))+
      ylab("Average Squad Age")
    
    
  })
  
  #Is player jersey number related to Overall ?
  
  Playerjersey<-reactive({
    Fifa %>%
      group_by(Jersey.Number) %>%
      summarise(Avg.Overall = sum(Overall)/length(Jersey.Number),
                Player.Count = sum(Jersey.Number))%>%
      arrange(-Avg.Overall)%>%
      ggplot(aes(x = Jersey.Number, y = Avg.Overall,col = ifelse(Avg.Overall < 70,"darkgrey", "Red")))+
      geom_point(position = "jitter")+
      theme(legend.position = "none")+
      geom_text_repel(aes(label = ifelse(Avg.Overall > 70, Jersey.Number, "")))
  })
  
  

  
  
  
  
  
  
  ####################### Best free kick takers in the game #########################
  BestFreekickers<-reactive({
    Fifa %>%
      arrange(-FKAccuracy, -Curve)%>%
      dplyr::select(Name, FKAccuracy, Curve, Age, Club)%>%
      head(10)
    
    
  })
  
  
  
  ####################### Most Unfit#########################
  MostUnfit<-reactive({
    Fifa %>%
      group_by(Name)%>%
      mutate(BMI = (Weight*0.453592/(Height)^2))%>%
      arrange(-BMI)%>%
      select(Name, BMI)%>%
      head(10)
    
    
  })
  
  
######  Variations with Age #########
  
  VariationAge<-reactive({
    ggplot(Fifa) +
      geom_tile(aes(Overall, Potential, fill = Age)) + 
      scale_fill_distiller(palette = "Spectral") + 
      theme( panel.grid.major = element_blank(),
             panel.grid.minor = element_blank(),
             panel.background = element_blank(), 
             axis.line = element_line(colour = "black"))
    
  })
  
  
  
  
  
  
  
}




