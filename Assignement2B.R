library(ggplot2)
library(dplyr)
install.packages("rlang")
library(readr)

penguins = read.csv("https://raw.githubusercontent.com/acatlin/data/refs/heads/master/penguin_predictions.csv")
head(penguins)
str(penguins)
table(penguins$sex)

#by analyzing the table we can see that male are greater in numbers
majority_class = names(which.max(table(penguins$sex)))
majority_class

#finding the Null Error Rate
null_error_rate = 1 - max(prop.table(table(penguins$sex)))

null_error_rate

#plot the distribution
ggplot(penguins, aes( x = sex, fill = sex)) +
  geom_bar() + 
  labs(title = " Class Distribution of Sex", x = "Sex", y = "Count") +
  theme_minimal()
#plot the distribution
penguins %>%
  count(sex) %>%
  mutate(sex = reorder(sex, n)) %>%
  ggplot(aes(x =sex, y = n, fill = sex)) +
  geom_col()

# better way and professional llms
penguins %>%
  count(sex) %>%
  mutate(
    percent = n / sum(n) * 100,
    sex = reorder(sex, -percent)
  ) %>%
  ggplot(aes(x =sex, y = percent, fill = sex)) +
  geom_col() +
  geom_text(
    aes(label = paste0(round(percent, 1), "%")),
    vjust = -0.3,
    size = 5
  ) +
  labs(
    title = "Class Distribution of Sex",
    x = "Sex",
    y = "Percentage"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

#recomputing predicted class using threshold

compute_metrics = function(data, threshold) {
  data$pred_class_thresh = ifelse(data$.pred_female > threshold, 1, 0)
  
  #Confusion matrix
  TP = sum(data$pred_class_thresh == 1 & data$sex == 1)
  FP = sum(data$pred_class_thresh == 1 & data$sex == 0)
  TN = sum(data$pred_class_thresh == 0 & data$sex == 0)
  FN = sum(data$pred_class_thresh == 0 & data$sex == 1)
  
  #Performance metrics
  accuracy = (TP + TN) / nrow(data)
  precision = ifelse((TP + FP) == 0, NA, TP / (TP + FP))
  recall = ifelse((TP + FN) == 0, NA, TP / (TP + FN))
  f1 = ifelse(is.na(precision) | is.na(recall) | (precision + recall) == 0, NA,
                      2 * precision * recall / (precision + recall))
              list(
                ConfusionMatrix = matrix(c(TP, FP, FN, TN), 
                                         nrow = 2,
                                         dimnames = list(
                                           Predicted = c("Positive", "Negative"),
                                           Actual = c("Positive", "Negative"))),
                Accuracy = accuracy,
                Precision = precision,
                Recall = recall,
                F1 = f1
              )
}

thresholds = c(0.2, 0.5, 0.8)
results = lapply(thresholds, function(t) compute_metrics(penguins, t))
names(results) = paste0("Threshold_", thresholds)
results

#presenting in a clear table

metrics_table = data.frame(
  Threshold = thresholds,
  Accuracy = sapply(results, function(x) x$Accuracy),
  Precision = sapply(results, function(x) x$Precision),
  Recall = sapply(results, function(x) x$Recall),
  F1 = sapply(results, function(x) x$F1)
)

metrics_table

#step 4 Threshold Use Cases can be find on my Quardo file

#threshold 0.2 is good to use when missing a positive is very costly like medical
# screening since we want to catch almost all patients even if some false 
#positives occur.

# threshold 0.8 is good to use when false positive are costly like fraud detection,
#we want only to flag extremely 
#likely causes to avoid wasting resources.



