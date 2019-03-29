ui <- dashboardPage(skin = "red",
                    dashboardHeader(title = "FIFA19 Analysis"),
                    
                    dashboardSidebar(width = 350,
                                     tags$head(
                                       tags$style(HTML("
                                                       .sidebar { height: 90vh; overflow-y: auto; }
                                                       
                                                       " ))),
                                     
                                     sidebarMenu(
                                       menuItem("Data", tabName = "data", icon = icon("dashboard")),
                                       menuItem("Menu", tabName = "Files", icon=icon("scale", lib = 'glyphicon'),
                                                menuItem("Squad Value in Millions", tabName = "da1", icon=icon("triangle-right", lib = 'glyphicon')),
                                                menuItem("Top Wage", tabName = "da2", icon=icon("triangle-right", lib = 'glyphicon')),
                                                menuItem("Super Stars", tabName = "da3", icon=icon("triangle-right", lib = 'glyphicon')),
                                                menuItem("Youngest Squad", tabName = "da4", icon=icon("triangle-right", lib = 'glyphicon')),
                                                menuItem("Player jersey", tabName = "da5", icon=icon("triangle-right", lib = 'glyphicon')),
                                                menuItem("Best Free kickers ", tabName = "da6", icon=icon("triangle-right", lib = 'glyphicon')),
                                                menuItem("Most Unfit", tabName = "da7", icon=icon("triangle-right", lib = 'glyphicon')),
                                                menuItem("Variation Age", tabName = "da8", icon=icon("triangle-right", lib = 'glyphicon')),
                                                menuItem("Age vs Wage", tabName = "da9", icon=icon("triangle-right", lib = 'glyphicon'))
                                                #menuItem("Clean Finsh", tabName = "da10", icon=icon("triangle-right", lib = 'glyphicon')),
                                                #menuItem("VolleyGoal_85", tabName = "da11", icon=icon("triangle-right", lib = 'glyphicon')),
                                               # menuItem("Penalties", tabName = "da12", icon=icon("triangle-right", lib = 'glyphicon'))
                                               )
                                           
                                     )),
                    dashboardBody(
                      
                      tabItems(
                        tabItem(tabName="data",
                                tabsetPanel(
                                  tabPanel("Data Files",
                                           wellPanel(div(style = 'overflow-x: scroll', DT::dataTableOutput('table'))
                                           ))
                                  
                                )),
                        
                        # FirST tab content
                        
                        tabItem(tabName = "da1",
                                # FirST tab content
                                tabPanel("Squad Value in Millions",
                                         wellPanel(fluidRow(plotlyOutput("graph1")))
                                         
                                )
                        ),
                        tabItem(tabName = "da2",
                                tabPanel("Top Wage",
                                         wellPanel(fluidRow(plotlyOutput("graph2")))
                                         
                                )
                        ),
                        tabItem(tabName = "da3",
                                tabPanel("Super Stars",
                                         wellPanel(fluidRow(plotlyOutput("graph3")))
                                         
                                )
                        ),
                      
                        tabItem(tabName = "da4",
                                # FirST tab content
                                
                                tabPanel("Youngest Squad",
                                         wellPanel(fluidRow(plotlyOutput("graph4")))
                                )
                        ),
                        tabItem(tabName = "da5",
                                # FirST tab content
                                
                                tabPanel("Player Jersey",
                                         wellPanel(fluidRow(plotlyOutput("graph5")))
                                )
                        ),
                        
                        tabItem(tabName = "da6",
                                
                                tabPanel("Best Freekickers",
                                         wellPanel(fluidRow( DT::dataTableOutput("graph6")))
                                         
                                )
                        ),
                         tabItem(tabName = "da7",
                                         # FirST tab content
                                         
                                         tabPanel("Most Unfit",
                                                  wellPanel(fluidRow(DT::dataTableOutput("graph7")))
                         )
                        ),
                        tabItem(tabName = "da8",
                                                
                                        tabPanel("Variation Age",
                                                wellPanel(fluidRow(plotlyOutput("graph8")))
                                                         
                               )                
                        ),
                        tabItem(tabName = "da9",
                                
                                tabPanel("Age vs Wage",
                                         wellPanel(fluidRow(plotlyOutput("graph9")))
                                         
                                )                
                         )
                        # tabItem(tabName = "da10",
                        #         
                        #         tabPanel("Best Clean Finishers",
                        #                  wellPanel(fluidRow( DT::dataTableOutput("graph10")))
                        #                  
                        #         )
                        # ),
                        # tabItem(tabName = "da11",
                        #         
                        #         tabPanel("VolleyGoal_85",
                        #                  wellPanel(fluidRow( DT::dataTableOutput("graph11")))
                        #                  
                        #         )
                        # ),
                        # tabItem(tabName = "da12",
                        #         
                        #         tabPanel("Penalties",
                        #                  wellPanel(fluidRow( DT::dataTableOutput("graph12")))
                        #                  
                        #         )
                        # )
                        
                        ))
                      
                    )
