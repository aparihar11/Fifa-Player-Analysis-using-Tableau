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
    output=getuseragg()
    output
  })
  
  ###########Graph 2############
  output$graph2<-renderPlotly({
    output=getpoker()
    output
    
  })
  
  ###########Graph 3############
  output$graph3<-renderPlotly({
    output=getusergender()
    output
  })
  
  ###########Graph 4############
  output$graph4<-renderPlotly({
    new<-getage()
    new
  })
  
  ###########Graph 5############
  output$graph5<-renderPlotly({
    new<-getcountry()
    new
  })
  
  ###########Graph 6############
  output$graph6<-renderPlotly({
    new<-getlos()
    new
  })
  
  ###########Graph 7############
  output$graph7<-renderPlot({
    new<-gettopapp()
    new
  })
  
  ###########Graph 8############
  output$graph8<-renderDataTable({
    new<-gettop()
    new
  })
  
  
  
  ########### User Aggregration Monthwise ##############
  getuseragg<-reactive({
    
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
  
  
  
  
  
  
  
  
  ########### Poker Monthwise ##############
  getpoker<-reactive({
    monthfreq <- unique(basetable[,c("USERID","poker_f2months",
                                     "poker_m4months",
                                     "poker_l2months")])
    names(monthfreq) <- c("USERID","Season Start(2 Months)",
                          "Mid-Season(4 Months)",
                          "End Season (2 Months)")
    monthfreq <- gather(monthfreq,Freq,value,-USERID)
    monthfreq <- monthfreq[complete.cases(monthfreq),]
    monthfreq$value <- as.character(monthfreq$value)
    
    x = factor(monthfreq$Freq,c("USERID","Season Start(2 Months)",
                                "Mid-Season(4 Months)",
                                "End Season (2 Months)"))
    y = monthfreq$value
    
    plot_ly(y=y, x=x, histfunc='sum', type = "histogram") %>%
      layout(title = "Poker Users by Time (Frequency)",
             yaxis=list(type='linear'))
    
    
    
  })
  
  ###########User gender ##############
  getusergender<-reactive({
    x = basetable$Gender
    
    plot_ly(x=x, type = "histogram") %>%
      layout(title = "Gambling Activity by Gender")
    
    
  })
  
  
  
  
  
  
  ###########Activity by age ##############
  getage<-reactive({
    userage <- unique(basetable[,c("AGE","ApplicationID")])
    userage <- userage[complete.cases(userage),]
    
    x = factor(userage$AGE)
    plot_ly(x=x, type = "histogram") %>%
      layout(title = "Activity by Age",
             yaxis=list(type='linear'),
             xaxis=list(tickangle = 270))
    
  })
  
  
  
  
  
  
  
  
  
  ####Country WISE PRODUCT USAGE Overall####
  getcountry<-reactive({
    
    x = basetable$Country
    
    plot_ly(x=x, type = "histogram") %>%
      layout(title = "Gambling Activity by Country")
    
    
    
  })
  
  #top Application by User count
  
  gettopapp<-reactive({
    counts<-sort(table(basetable$ApplicationID))
    top_5_countries<-tail(counts, 5)
    barplot(top_5_countries, main="Top Applications by user count")
    
  })
  
  
  
  ###########LOS ##############
  getlos<-reactive({
    
    los <- unique(basetable[,c("USERID","udarLOS")])
    los <- los[complete.cases(los),]
    
    x = los$udarLOS
    
    plot_ly(x=x, type = "histogram") %>%
      layout(title = "Frequency of LOS (Length of Subscription in Gambling) ")
    
    
  })
  
  
  
  
  
  
  
  ####################### Top PLAYERS #########################
  gettop<-reactive({
    basetable_clean_professinals<- basetable %>% filter(poker_m4months > 100 & poker_l2months >= 200 & poker_f2months>100)
    mydata_clean_unique<-unique(basetable_clean_professinals[,c("USERID","poker_f2months","poker_m4months","poker_l2months")])
    dset1<-head(mydata_clean_unique,10)
    
    
  })
  
  
  
  
  
  
  
}




