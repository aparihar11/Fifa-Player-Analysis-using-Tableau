#install.packages("ggthemes", repos = "https://cran.rstudio.com") #installing package ggthemes
###Loading all packages
library(data.table) # Imprting data
library(tidyverse) # Data manupulation
library(tibble) # used to create tibbles
library(tidyr) # used to tidy up data
library(dplyr) # used for data manipulation
library(DT) # used for datatable function for displaying dataset
library(ggthemes) #for using themes for plots
library(scatterplot3d)
library(parallel)
#detectCores()

setwd("C:/Users/aparihar/Desktop/retakes/R_project")

#importing dataset

Fifa <- read.csv("data.csv",header = T, stringsAsFactors = F) 

Fifa$ValueLast <- sapply(strsplit(as.character(Fifa$Value), ""), tail, 1)

Fifa$WageLast <- sapply(strsplit(as.character(Fifa$Wage), ""), tail, 1)

Fifa$Release.Clause.Last <- sapply(strsplit(as.character(Fifa$Release.Clause), ""), tail, 1)

extract <- function(x){
  regexp <- "[[:digit:]]+"
  str_extract(x, regexp)
}

temp1 <- sapply(Fifa$Value, extract)

Fifa$Value <- as.numeric(temp1)

temp2 <- sapply(Fifa$Wage, extract)

Fifa$Wage <- as.numeric(temp2)

temp3 <- sapply(Fifa$Release.Clause, extract)

Fifa$Release.Clause <- as.numeric(temp3)

Fifa$Wage <- ifelse(Fifa$WageLast == "M", Fifa$Wage * 1000000, Fifa$Wage * 1000)


Fifa$Value <- ifelse(Fifa$ValueLast == "M", Fifa$Value * 1000000, Fifa$Value * 1000)

Fifa$Release.Clause <- ifelse(Fifa$Release.Clause.Last == "M", Fifa$Release.Clause * 1000000, Fifa$Release.Clause * 1000)

Fifa$Contract.Valid.Until <- as.numeric(Fifa$Contract.Valid.Until)

Fifa$Remaining.Contract <- Fifa$Contract.Valid.Until - 2019

Fifa$Height.Inch <- str_split(Fifa$Height,"'") 

temp4 <- sapply(Fifa$Weight, extract)

Fifa$Weight <- as.numeric(temp4)

temp5 <- strsplit(Fifa$Height, "'")

for (i in 1:length(temp5)){
  temp5[[i]] <- as.numeric(temp5[[i]])
} 

for (i in 1:length(temp5)){
  temp5[[i]] <- (temp5[[i]][1] * 12 ) + temp5[[i]][2]
}

temp6 <- as.numeric(unlist(temp5))

Fifa$Height <- temp6

dff <- Fifa[,29:54]

def_fun <- function(x){
  a <- strsplit(x, '\\+')
  for (i in length(a)){
    b <- sum(as.numeric(a[[i]]))
  }
  return (b)
}

for (i in 1: ncol(dff)){
  dff[i] <- apply(dff[i], 1, FUN = def_fun)
}





Fifa[,29:54] <- NULL



Fifa <- cbind.data.frame(Fifa, dff)






#####Cheal Finsh
longpass_85 <- subset(Fifa, LongPassing > 85 & ShortPassing > 85 & Vision > 85)
longpass_85<-longpass_85[1,10]

#####Volley Goal--Players who can score lightning fast Volley goals
VolleyGoal_85 <- subset(Fifa, Volleys>85  & Curve > 85 & ShotPower > 85)
VolleyGoal_85<-VolleyGoal_85[,1:10]

Penalties <- subset(Fifa, Finishing>80  & Vision > 80 & Penalties > 80)
Penalties<-Penalties[,1:10]


###Linear Regression Analysis
Striker_data <- filter(Fifa, `Position` == "ST")
model <- lm(Overall ~ 
              Acceleration + Agility + BallControl + 
              Finishing + LongShots, data = Striker_data ) #filtering fifa data for players who are strikers


summary(model)
anova(model)


###########################################################
#####################CLUSTER ANALYSIS#####################
###########################################################


fifa_data <- read_csv("data.csv") %>% select(-X1)


fifa_data <- fifa_data %>%
  mutate(ValueMultiplier = ifelse(str_detect(Value, "K"), 1000, ifelse(str_detect(Value, "M"), 1000000, 1))) %>%
  mutate(ValueNumeric_pounds = as.numeric(str_extract(Value, "[[:digit:]]+\\.*[[:digit:]]*")) * ValueMultiplier) %>%
  mutate(Position = ifelse(is.na(Position), "Unknown", Position))


fifa_data <- fifa_data %>%
  mutate(WageMultiplier = ifelse(str_detect(Wage, "K"), 1000, ifelse(str_detect(Wage, "M"), 1000000, 1))) %>%
  mutate(WageNumeric_pounds = as.numeric(str_extract(Wage, "[[:digit:]]+\\.*[[:digit:]]*")) * WageMultiplier)


positions <- unique(fifa_data$Position)

gk <- "GK"
defs <- positions[str_detect(positions, "B$")]
mids <- positions[str_detect(positions, "M$")]
f1 <- positions[str_detect(positions, "F$")]
f2 <- positions[str_detect(positions, "S$")]
f3 <- positions[str_detect(positions, "T$")]
f4 <- positions[str_detect(positions, "W$")]
fwds <- c(f1, f2, f3, f4)

fifa_data <- fifa_data %>% 
  mutate(PositionGroup = ifelse(Position %in% gk, "GK", ifelse(Position %in% defs, "DEF", ifelse(Position %in% mids, "MID", ifelse(Position %in% fwds, "FWD", "Unknown")))))

fifa_data <- fifa_data %>%
  mutate(AgeGroup = ifelse(Age <= 20, "20 and under", ifelse(Age > 20 & Age <=25, "21 to 25", ifelse(Age > 25 & Age <= 30, "25 to 30", ifelse(Age > 30 & Age <= 35, "31 to 35", "Over 35")))))
fifa_data <- fifa_data  %>%
  mutate(AttackingRating = (Finishing + LongShots + Penalties + ShotPower + Positioning) /5)

fifa_data %>%
  filter(PositionGroup %in% c("MID", "FWD")) %>%
  group_by(Club) %>%
  summarise(NumberOfAttackers = n(), TeamAttackingRating = mean(AttackingRating)) %>%
  arrange(desc(TeamAttackingRating)) %>% head(50) %>%
  DT::datatable()

data_cluster <- fifa_data %>%
  filter(Position != "Unknown") %>%
  filter(Position != "GK") %>%
  mutate(RoomToGrow = Potential - Overall) %>%
  select_if(is.numeric) %>%
  select(-ID, -'Jersey Number', -AttackingRating, -starts_with("Value"), - starts_with("Wage"), -starts_with("GK"), -Overall)


scaled_data <- scale(data_cluster)

set.seed(109)
# Initialize total within sum of squares error: wss
wss <- 0
# For 1 to 30 cluster centers
for (j in 1:30) {
  km.out <- kmeans(scaled_data, centers = j, nstart = 20)
  # Save total within sum of squares to wss variable
  wss[j] <- km.out$tot.withinss
}


# create a DF to use in a ggplot visualisation
wss_df <- data.frame(num_cluster = 1:30, wgss = wss)

# plot to determine optimal k
ggplot(data = wss_df, aes(x=num_cluster, y= wgss)) + 
  geom_line(color = "lightgrey", size = 2) + 
  geom_point(color = "green", size = 4) +
  theme_fivethirtyeight() +
  geom_curve(x=14, xend=8, y=300000, yend= 290500, arrow = arrow(length = unit(0.2,"cm")), size =1, colour = "purple") +
  geom_text(label = "k = 8\noptimal level", x=14, y= 290000, colour = "purple") +
  labs(title = "Using Eight Clusters To Group Players", subtitle = "Selecting the point where the elbow 'bends', or where the slope of \nthe Within groups sum of squares levels out")



gc()
k=8
wisc.km <- kmeans(scale(data_cluster), centers = k, nstart = 20)




# add the cluster group back to the original DF for all players other than GK and Unknown
cluster_data <- fifa_data %>%
  filter(Position != "Unknown") %>%
  filter(Position != "GK") %>%
  mutate(Cluster = wisc.km$cluster)


cluster_analysis <- cluster_data %>%
  select(ID, Name, Club, Age, PositionGroup, Overall, Cluster, ValueNumeric_pounds)

# how have the clusters been split between position groups
table(cluster_analysis$Cluster, cluster_analysis$PositionGroup)


# create an arranged DF for analysis

p  <- cluster_analysis %>%
  mutate(Cluster = paste("Cluster: ", Cluster, sep = "")) %>%
  arrange(desc(Overall)) %>% 
  group_by(Cluster) %>%
  slice(1:20) %>%
  mutate(Under27 = ifelse(Age < 27, "Yes", "No")) %>%
  ggplot(aes(x= Overall, y= ValueNumeric_pounds)) +
  geom_point(position = "jitter", shape = 21, color = "black", size = 2, aes(text = paste(Name, PositionGroup), fill = Under27)) +
  scale_fill_manual(values = c("purple", "green")) +
  scale_y_continuous(labels = dollar_format(prefix = "â¬")) +
  ggtitle("Player's overall rating plotted against their value for the \n20 highest rated players in each cluster") +
  facet_wrap(~ factor(Cluster), scales = "free", ncol = 2) +
  theme_fivethirtyeight() +
  theme(legend.position = "none", strip.text = element_text(face = "bold", size = 12))

# plot output
ggplotly(p, height = 700, width = 900)


















