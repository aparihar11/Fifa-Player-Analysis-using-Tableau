#install.packages("ggthemes", repos = "https://cran.rstudio.com") #installing package ggthemes
###Loading all packages
library(data.table) # Imprting data
library(tidyverse) # Data manupulation
library(tibble) # used to create tibbles
library(tidyr) # used to tidy up data
library(dplyr) # used for data manipulation
library(DT) # used for datatable function for displaying dataset
library("ggthemes") #for using themes for plots

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

)
write.csv(Fifa,'basetable.csv')
