library(ggplot2)
library(dplyr)
install.packages("rlang")
library(readr)

penguins = read.csv("https://raw.githubusercontent.com/acatlin/data/refs/heads/master/penguin_predictions.csv")
head(penguins)
str(penguins)