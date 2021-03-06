# Arkansas Population 5 Year Projection

# Installs & Libraries

install.packages("data.table") # For working with data sets
install.packages("tidyr") # for cleaning
install.packages("reshape2") # for cleaning
install.packages("dplyr") #  for joins
install.packages("ggplot2") # for visuals

library(data.table)
library(tidyr)
library(dplyr)
library(reshape2)
library(ggplot2)

# Getting the dataset from census.gov (Pop data from 2010-2019)

# This location will be where the file is downloaded
setwd("C:/Users/Owner/Desktop/School/Prog in R C997")

url <- 'http://www2.census.gov/programs-surveys/popest/datasets/2010-2019/national/totals/nst-est2019-alldata.csv'

local <- file.path("population_data_2010_2019")
download.file(url, local)
pop_data = fread(local)




# Selecting AR data and Pivoting the dataframe

pop_data <- pop_data %>%
  # Selecting desired cols
  select(NAME, POPESTIMATE2010:POPESTIMATE2019) %>%
  # Filtering for Arkansas
  subset(NAME == "Arkansas") %>%
  # Pivoting the data
  gather('col', 'Population', POPESTIMATE2010:POPESTIMATE2019) %>%
  separate('col', c('a', 'Year'), sep='(?<=[A-Za-z])(?=[0-9])') %>%
  # Selecting final cols
  select(Year, Population)

# Changing Year data type
pop_data$Year <- as.integer(pop_data$Year)





# Creating the linear regression model
pop.lm <- lm(
  formula = Population ~ Year,
  data = pop_data
)

# Summarizing the model
summary(pop.lm)


# Predicting new values with model for the next 5 years and adding to a new dataframe
newdata = data.frame(Year = c(2021, 2022, 2023, 2024, 2025))

newdata$Population <- predict(pop.lm, newdata=newdata)

View(newdata)

# Plotting the results
pop_data$group <- 1
newdata$group <- 2

pop_data_final <- rbind(pop_data, newdata)

p <- ggplot(pop_data_final,
            aes(x=Year,y=Population,
                group = group,
                col=group)) +
      geom_point(size=3) +
      geom_smooth(method = "lm", formula = y ~ x, colour = "red",                     size=1, fullrange=TRUE) +
      ggtitle("AR Population 5 Year Projection from 2020") +
      theme(legend.position = "none")

p